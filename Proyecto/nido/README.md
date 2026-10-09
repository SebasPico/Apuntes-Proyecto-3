# Nido

Aplicación Flutter para organizar suministros del hogar por espacios, compartir inventarios familiares y acceder a cada espacio mediante un código QR.

## Arquitectura

- `lib/models`: entidades canónicas independientes de Firebase (`Usuario`, `GrupoFamiliar`, `Espacio`, `Producto`).
- `lib/domain/repositories`: contratos de acceso a datos consumidos por los controladores.
- `lib/data/repositories`: implementaciones Firebase Authentication y Cloud Firestore.
- `lib/controllers`: coordinación entre vistas y dominio.
- `lib/views`: pantallas Flutter.

Firebase Authentication administra credenciales y sesiones. Firestore almacena perfiles, grupos, espacios y productos; sus listeners mantienen actualizados el inicio y el inventario entre dispositivos, con la persistencia offline que provee Firestore en Android e iOS. SQLite ya no es la fuente de datos.

## Requisitos de Firebase

1. Configura el proyecto Firebase para cada plataforma con FlutterFire CLI (`flutterfire configure`). Android cuenta con el plugin Google Services y su archivo local de configuración; iOS debe tener la configuración generada (`GoogleService-Info.plist` / `firebase_options.dart`) antes de ejecutarse.
2. En Firebase Authentication, habilita el proveedor **Correo electrónico/contraseña**.
3. Crea Cloud Firestore y despliega las reglas incluidas:

   ```bash
   firebase deploy --only firestore:rules
   ```

4. Ejecuta `flutter pub get` y luego `flutter run`.

El wrapper de Gradle actual requiere JDK 21. Si Flutter selecciona otro JDK, configura el JDK 21 para Android antes de compilar.

La aplicación no usa cuentas, grupos ni productos de las antiguas tablas SQLite. Esos datos locales no se migran automáticamente a Firebase; cada usuario debe registrarse de nuevo.

## Datos en Firestore

- `users/{uid}`: perfil vinculado al UID de Firebase Authentication.
- `groups/{groupId}`: nombre, código de invitación, creador y miembros.
- `group_codes/{code}`: índice privado por código de invitación.
- `groups/{groupId}/spaces/{spaceId}`: espacios con icono simbólico estable y color.
- `groups/{groupId}/spaces/{spaceId}/products/{productId}`: productos e inventario.

Los códigos QR contienen un identificador `nido://space/{groupId}/{spaceId}`. El lector acepta códigos de Nido y solo abre espacios del grupo activo.

## Funcionalidad conectada

- Registro e inicio de sesión con Firebase Authentication.
- Crear y unirse a grupos con código de invitación.
- Crear espacios y verlos sincronizados en tiempo real.
- Generar un QR real por espacio y escanearlo con la cámara.
- Crear, editar, eliminar y ajustar productos; los cambios de cantidad se aplican dentro de una transacción de Firestore.
- Consultar alertas persistentes cuando un producto cruza su mínimo o se agota; tocar una alerta abre y resalta el producto.
- Recibir notificaciones push en dispositivos registrados, si el usuario concede el permiso.

## Activar notificaciones

Las alertas del historial se crean desde Cloud Functions para evitar que un cliente suplante avisos. Para compilar y desplegar la función:

1. Usa Node.js 22 e instala Firebase CLI (`npm install -g firebase-tools`).
2. Inicia sesión en Firebase CLI y selecciona el proyecto Firebase correcto (`firebase use <project-id>`).
3. Desde la raíz del proyecto instala las dependencias bloqueadas de la función:

   ```bash
   npm --prefix functions ci
   ```

4. Despliega reglas y función desde la raíz del proyecto:

   ```bash
   firebase deploy --only firestore:rules,functions
   ```

5. En iOS, configura APNs en Firebase y genera la configuración/entitlements de notificaciones para la app. Android solicita el permiso de notificaciones en tiempo de ejecución.

El despliegue de Cloud Functions requiere un plan de Firebase que permita Functions. Las notificaciones push requieren que FCM esté habilitado para el proyecto y que el usuario otorgue permiso. Si se deniega, el historial dentro de la aplicación sigue disponible. Los avisos se conservan en `groups/{groupId}/notifications`; cada integrante puede marcar los avisos como leídos sin alterar el estado de lectura de los demás.
