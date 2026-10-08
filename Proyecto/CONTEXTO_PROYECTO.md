# Contexto del Proyecto — App de Gestión de Suministros del Hogar mediante QR

> Este archivo resume toda la documentación de gestión del proyecto (propuesta, acta de constitución,
> especificación de requerimientos, EDT, plan integrado y backlog) en un solo documento de referencia,
> pensado para dar contexto a un asistente de IA (o a cualquier desarrollador nuevo) antes de empezar
> a escribir código bajo arquitectura **MVC**.

---

## 1. Resumen del proyecto

**Nombre:** Aplicación móvil para la gestión de suministros del hogar mediante códigos QR
**Autor:** Sebastian Pico Afanador — Facultad de Ingeniería de Sistemas e Informática (UPB)
**Asesor:** Lenin Javier Serrano Gil

**Problema que resuelve:** en los hogares, el inventario de suministros (aseo, alimentos no perecederos,
baño, limpieza) se gestiona de forma informal (listas en papel, memoria, chats). Esto genera desabastecimiento
sorpresivo, compras duplicadas y falta de visibilidad entre los integrantes del hogar, especialmente cuando
el inventario está disperso en distintas zonas de la vivienda.

**Solución:** app móvil que permite a un grupo familiar:
- Organizar el hogar en **espacios** (cocina, baño, lavado, etc.), cada uno con un **código QR único**.
- Escanear el QR de un espacio para abrir directamente su inventario.
- Registrar y actualizar productos por espacio (nombre, cantidad, cantidad mínima, prioridad).
- Generar automáticamente una **lista de compras** cuando un producto llega a su mínimo.
- Sincronizar todo en **tiempo real** entre los dispositivos del grupo familiar.
- Recibir **notificaciones push** cuando un producto se agota o llega al mínimo.

**Diferencial frente a la competencia** (CROLIST, Pantry Check, Home Stock, QR Pantry, Sortly, etc.):
ninguna combina simultáneamente organización jerárquica por espacios físicos + QR por zona +
colaboración familiar en tiempo real, sin depender de sensores IoT costosos.

---

## 2. Alcance

**Incluye:** autenticación, grupos familiares, espacios, QR, inventario, lista de compras,
sincronización en tiempo real, notificaciones push, vista consolidada, exportación de QR.

**No incluye (fuera de alcance / Won't have):**
- Reconocimiento automático de productos vía escaneo de recibos (RF21 — trabajo futuro).
- Integración con supermercados o e-commerce.
- Sensores físicos / IoT.
- Versión web o de escritorio.

**Restricciones clave:**
- Proyecto desarrollado por **una sola persona**.
- Cronograma fijo de 16 semanas (académico).
- Herramientas de plan gratuito: Android Studio, GitHub, Firebase (Spark).
- Depende de conexión a internet para sincronización en tiempo real; se mitiga con modo offline (RNF02).

---

## 3. Stack tecnológico (propuesto)

> ⚠️ Asunción explícita: los documentos de gestión mencionan Android Studio + Firebase como herramientas
> y exigen compatibilidad Android/iOS con un solo desarrollador (RNF06). Se asume el siguiente stack;
> ajústalo si el plan real es otro.

- **Frontend móvil:** Flutter (Dart) — un solo codebase para Android e iOS, integrable en Android Studio.
- **Backend / datos:** Firebase
  - **Firebase Authentication** → registro/login (RF01)
  - **Cloud Firestore** → base de datos NoSQL en tiempo real (grupos, espacios, inventario, lista de compras)
  - **Firebase Cloud Messaging** → notificaciones push (RF16)
  - **Firebase Storage** (opcional) → si se guardan imágenes de productos o QR exportados
- **Generación/lectura de QR:** librerías `qr_flutter` (generación) y `mobile_scanner` o `qr_code_scanner` (lectura).
- **Control de versiones:** GitHub.
- **Modo offline:** persistencia local de Firestore (offline persistence) + cola de sincronización diferida (RNF02).

---

## 4. Arquitectura MVC aplicada al proyecto

La app se organizará bajo **MVC** (Model – View – Controller), adaptado a Flutter. La idea es mantener
una separación estricta entre:

- **Model:** entidades de datos puras y su acceso a fuentes de datos (Firestore, almacenamiento local).
  No conoce nada de la UI.
- **View:** widgets de Flutter (pantallas y componentes visuales). Solo se encargan de mostrar datos y
  capturar eventos del usuario; no contienen lógica de negocio ni llamadas directas a Firebase.
- **Controller:** intermediario entre View y Model. Contiene la lógica de negocio, valida datos, orquesta
  llamadas a los repositorios/servicios (Model) y expone el estado a la View (por ejemplo, mediante
  `ChangeNotifier`/Provider, Riverpod o un gestor de estado equivalente).

### 4.1 Estructura de carpetas propuesta

```
lib/
├── main.dart
├── app.dart                         # configuración raíz de la app (rutas, tema)
│
├── models/                          # MODEL: entidades puras (sin lógica de UI ni de red)
│   ├── usuario.dart
│   ├── grupo_familiar.dart
│   ├── espacio.dart
│   ├── producto.dart
│   ├── item_lista_compras.dart
│   └── historial_cambio.dart
│
├── data/                            # MODEL: acceso a datos (Firestore, Auth, almacenamiento local)
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── grupo_repository.dart
│   │   ├── espacio_repository.dart
│   │   ├── inventario_repository.dart
│   │   ├── lista_compras_repository.dart
│   │   └── notificaciones_repository.dart
│   └── services/
│       ├── firebase_service.dart
│       ├── qr_service.dart          # generación/lectura de QR
│       └── sync_service.dart        # sincronización en tiempo real / offline
│
├── controllers/                     # CONTROLLER: lógica de negocio y estado
│   ├── auth_controller.dart
│   ├── grupo_controller.dart
│   ├── espacio_controller.dart
│   ├── inventario_controller.dart
│   ├── lista_compras_controller.dart
│   └── notificaciones_controller.dart
│
├── views/                           # VIEW: pantallas (una carpeta por módulo funcional)
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── registro_screen.dart
│   ├── grupo_familiar/
│   │   ├── crear_grupo_screen.dart
│   │   └── unirse_grupo_screen.dart
│   ├── espacios/
│   │   ├── espacios_screen.dart
│   │   ├── espacio_detalle_screen.dart
│   │   └── escanear_qr_screen.dart
│   ├── inventario/
│   │   ├── inventario_screen.dart
│   │   └── producto_form_screen.dart
│   ├── lista_compras/
│   │   └── lista_compras_screen.dart
│   └── consolidado/
│       └── vista_consolidada_screen.dart
│
├── widgets/                         # VIEW: componentes reutilizables (tarjetas, badges de prioridad, etc.)
│   ├── producto_card.dart
│   ├── prioridad_badge.dart
│   └── qr_widget.dart
│
└── utils/                           # utilidades transversales (validadores, constantes, formatos)
    ├── constants.dart
    └── validators.dart
```

### 4.2 Flujo típico (ejemplo: registrar un producto — RF08)

1. **View** (`producto_form_screen.dart`): el usuario llena el formulario y presiona "Guardar".
2. La View llama a un método del **Controller** (`inventario_controller.dart`), pasándole los datos crudos del formulario.
3. El **Controller** valida los datos (usando `utils/validators.dart`), construye un objeto `Producto` (**Model**)
   y llama al **Repository** correspondiente (`inventario_repository.dart`).
4. El **Repository** (parte del Model/capa de datos) persiste el producto en Firestore.
5. Firestore notifica el cambio en tiempo real → el **Controller** actualiza su estado →
   la **View** se redibuja automáticamente (gracias al gestor de estado) mostrando el nuevo producto,
   sin necesidad de recargar manualmente.

Este mismo patrón se repite para cada módulo (espacios, lista de compras, notificaciones, etc.).

---

## 5. Módulos funcionales y trazabilidad con requerimientos

| Módulo (EDT) | Carpeta principal | Requerimientos clave |
| --- | --- | --- |
| Usuarios y grupo familiar | `auth/`, `grupo_familiar/` | RF01–RF04 |
| Espacios del hogar y QR | `espacios/` | RF05–RF07, RF19 |
| Inventario | `inventario/` | RF08–RF11, RF20 |
| Lista de compras | `lista_compras/` | RF12–RF14 |
| Sincronización y notificaciones | `data/services/sync_service.dart`, `notificaciones/` | RF15, RF16, RNF01, RNF02 |
| Vista consolidada y filtros | `consolidado/` | RF17, RF18 |

**No funcionales a tener presentes durante el desarrollo:**
- RNF01: sincronización < 3 s en condiciones normales de red.
- RNF02: consulta e inventario offline con sincronización diferida al reconectar.
- RNF03: acciones principales (escanear QR, agregar producto, marcar comprado) en máx. 3 toques.
- RNF04: datos personales cifrados / política de privacidad.
- RNF05: soportar ≥ 6 integrantes y ≥ 15 espacios sin degradar rendimiento.
- RNF06: compatibilidad Android e iOS.
- RNF07: arquitectura modular (justamente lo que MVC + esta estructura de carpetas busca garantizar).
- RNF08: respaldo de datos (backup en la nube vía Firestore).

---

## 6. Modelo de datos (colecciones Firestore sugeridas)

```
usuarios/{uid}
  - nombre, email, grupoFamiliarId

gruposFamiliares/{grupoId}
  - nombre, codigoAcceso, integrantes: [uid, ...]

espacios/{espacioId}
  - grupoFamiliarId, nombre, color, icono, qrCode

productos/{productoId}
  - espacioId, nombre, cantidad, unidad, cantidadMinima, prioridad, estado

listaCompras/{itemId}
  - grupoFamiliarId, productoId (opcional si es manual), nombre, cantidadDeseada, comprado

historialCambios/{cambioId}
  - grupoFamiliarId, productoId, usuarioId, accion, fecha
```

---

## 7. Orden sugerido de implementación (según backlog priorizado)

Siguiendo el backlog priorizado (valor + riesgo + dependencias), el orden recomendado para ir
construyendo módulo por módulo es:

1. RF01 (registro/login) → RF02 (crear grupo) → RF03 (unirse a grupo)
2. RF05 (CRUD espacios) → RF06 (generar QR) → RF07 (escanear QR)
3. RF08 (registrar producto) → RF11 (prioridad) → RF09 (editar cantidad)
4. RF12 (lista de compras automática) — **alto riesgo, planificar con margen**
5. RF15 (sincronización en tiempo real) — **alto riesgo, planificar con margen**
6. RF14 (marcar comprado) → RF16 (notificaciones push)
7. RF13 (agregar manual) → RF10 (eliminar producto) → RF04 (salir del grupo)
8. RF17 (vista consolidada) → RF19 (exportar QR) → RF20 (historial) → RF18 (filtros)

Las historias con **Riesgo Alto** (RF12 y RF15) deben abordarse tan pronto como sus dependencias lo
permitan, para reducir incertidumbre técnica temprano en el proyecto.

---

## 8. Cómo usar este archivo

Este documento debe darse como contexto inicial a cualquier asistente de IA (o desarrollador) antes de
pedirle que genere código, para que:
- Respete la separación Model / View / Controller descrita en la sección 4.
- Ubique cada archivo nuevo en la carpeta correcta según la sección 4.1.
- Nombre los módulos y entidades de forma consistente con la sección 6 (modelo de datos) y la
  Especificación de Requerimientos.
- Tenga en cuenta los requerimientos no funcionales (sección 5) al tomar decisiones de diseño
  (por ejemplo, no bloquear la UI mientras se sincroniza, o soportar modo offline desde el inicio).
