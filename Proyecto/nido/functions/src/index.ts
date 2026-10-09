import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { onDocumentWritten } from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();
const messaging = getMessaging();

type Product = {
  nombre?: string;
  cantidad?: number;
  cantidadMinima?: number;
  creadoPor?: string;
  actualizadoPor?: string;
};

export const notifyLowInventory = onDocumentWritten(
  "groups/{groupId}/spaces/{spaceId}/products/{productId}",
  async (event) => {
    const after = event.data?.after;
    const before = event.data?.before;
    if (!after?.exists) return;

    const current = after.data() as Product;
    const previous = before?.exists ? before.data() as Product : undefined;
    const currentQuantity = current.cantidad ?? 0;
    const currentMinimum = current.cantidadMinima ?? 0;
    const previousQuantity = previous?.cantidad ?? Number.POSITIVE_INFINITY;
    const previousMinimum = previous?.cantidadMinima ?? currentMinimum;

    const becameEmpty = currentQuantity === 0 && previousQuantity > 0;
    const crossedMinimum =
      currentQuantity <= currentMinimum &&
      previousQuantity > previousMinimum &&
      currentQuantity > 0;

    if (!becameEmpty && !crossedMinimum) return;

    const { groupId, spaceId, productId } = event.params;
    const groupRef = db.collection("groups").doc(groupId);
    const [groupSnapshot, spaceSnapshot] = await Promise.all([
      groupRef.get(),
      groupRef.collection("spaces").doc(spaceId).get(),
    ]);
    if (!groupSnapshot.exists || !spaceSnapshot.exists) return;

    const group = groupSnapshot.data();
    const members = Array.isArray(group?.integrantesIds)
      ? group.integrantesIds.filter((uid): uid is string => typeof uid === "string")
      : [];
    if (members.length === 0) return;

    const actorUid = current.actualizadoPor ?? current.creadoPor ?? "";
    const notificationRef = groupRef.collection("notifications").doc(event.id);
    const created = await db.runTransaction(async (transaction) => {
      const existing = await transaction.get(notificationRef);
      if (existing.exists) return false;
      transaction.create(notificationRef, {
        grupoId: groupId,
        espacioId: spaceId,
        productoId: productId,
        nombreProducto: current.nombre ?? "Producto",
        nombreEspacio: spaceSnapshot.data()?.nombre ?? "Espacio",
        tipo: becameEmpty ? "agotado" : "minimo",
        cantidad: currentQuantity,
        cantidadMinima: currentMinimum,
        usuarioId: actorUid,
        leidaPor: [],
        createdAt: new Date(),
      });
      return true;
    });
    if (!created) return;

    const recipientIds = members.filter((uid) => uid !== actorUid);
    if (recipientIds.length === 0) return;

    const tokenSnapshots = await Promise.all(
      recipientIds.map((uid) =>
        db.collection("users").doc(uid).collection("devices").get(),
      ),
    );
    const tokenDocs = tokenSnapshots.flatMap((snapshot) => snapshot.docs);
    const tokens = [...new Set(
      tokenDocs
        .map((doc) => doc.get("token"))
        .filter((token): token is string => typeof token === "string"),
    )];
    if (tokens.length === 0) return;

    const title = becameEmpty
      ? `${current.nombre ?? "Un producto"} se agotó`
      : `${current.nombre ?? "Un producto"} llegó al mínimo`;
    const body = `${spaceSnapshot.data()?.nombre ?? "Espacio"} · ${currentQuantity} disponibles`;
    const response = await messaging.sendEachForMulticast({
      tokens,
      notification: { title, body },
      data: {
        grupoId: groupId,
        espacioId: spaceId,
        productoId: productId,
        avisoId: event.id,
      },
      android: {
        priority: "high",
        notification: { channelId: "nido_alertas" },
      },
      apns: {
        payload: { aps: { sound: "default" } },
      },
    });

    const invalidTokens = response.responses
      .map((result, index) => ({ result, token: tokens[index] }))
      .filter(({ result }) =>
        result.error?.code === "messaging/registration-token-not-registered" ||
        result.error?.code === "messaging/invalid-registration-token",
      )
      .map(({ token }) => token);
    if (invalidTokens.length > 0) {
      await Promise.all(
        tokenDocs
          .filter((doc) => invalidTokens.includes(doc.get("token") as string))
          .map((doc) => doc.ref.delete()),
      );
    }

    if (response.failureCount > 0) {
      logger.warn("Some inventory notifications could not be delivered", {
        groupId,
        notificationId: event.id,
        failures: response.failureCount,
      });
    }
  },
);
