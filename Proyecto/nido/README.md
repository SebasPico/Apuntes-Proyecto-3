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
- Ver la lista de reposición y alertas al cargar esas pantallas.

Las notificaciones push remotas, el historial de cambios y la exportación del QR como archivo aún requieren servicios/funciones adicionales; no se simulan como si ya estuvieran implementadas.
