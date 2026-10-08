Aplicación móvil para la gestión de suministros del hogar mediante códigos QR
Especificación de Interfaces (UI) para Desarrollo
Guía de pantallas, campos y comportamiento para instruir al desarrollo (manual o asistido por IA)
Sebastian Pico Afanador · sebastian.pico.2022@upb.edu.co
Facultad de Ingeniería de Sistemas e Informática · Agosto 2026
# 1. Propósito de este documento
Este documento traduce la Especificación de Requerimientos, el Backlog Priorizado y la EDT del proyecto en una guía concreta de interfaces (pantallas), para que puedan construirse — de forma manual o con ayuda de una herramienta de IA generativa de código o de diseño — sin ambigüedad sobre qué datos capturar, qué debe mostrarse en cada momento y cómo se conectan las pantallas entre sí.
Cada pantalla se describe con la misma estructura, para que puedas copiar la sección correspondiente y usarla como instrucción (prompt) al construir esa parte de la aplicación:
Objetivo: para qué existe la pantalla.
Requerimientos relacionados: los RF/RNF de la Especificación de Requerimientos que satisface.
Campos y elementos: qué captura o qué controles tiene, con su tipo y si es obligatorio.
Qué debe mostrar: la información que se lee en pantalla (no se captura, se presenta).
Acciones del usuario: qué botones o gestos están disponibles y qué disparan.
Validaciones y reglas de negocio: qué debe impedir, avisar o calcular el sistema.
Navegación: a qué otra pantalla lleva cada acción.
Nota: Cuando le pidas a una IA que genere una pantalla, pégale el bloque completo de esa pantalla (objetivo + campos + acciones + validaciones + navegación); entre más completo el contexto que le des, menos supuestos incorrectos hará sobre lo que debe construir.
# 2. Lineamientos generales de diseño (aplican a todas las pantallas)
Plataformas: Android e iOS (RNF06); usar un solo diseño responsivo o componentes equivalentes en ambas plataformas.
Máximo 3 toques para las acciones principales: escanear QR, agregar producto y marcar como comprado (RNF03).
Código de color por prioridad de producto, consistente en toda la app: Alta = rojo, Media = amarillo/ámbar, Baja = verde.
Cada espacio del hogar tiene un color propio (elegido por el usuario) que se usa como acento en su tarjeta del Home, su encabezado de inventario y su QR, para reconocerlo de un vistazo.
Estados vacíos: toda lista (espacios, productos, lista de compras, notificaciones) debe tener un mensaje y un llamado a la acción cuando no hay datos aún (p. ej. "Aún no tienes espacios, crea el primero").
Estados de carga y error: mostrar un indicador de carga en operaciones de red y mensajes de error claros y accionables, nunca códigos técnicos.
Indicador de sin conexión: un banner persistente cuando no hay internet, ver Pantalla 15.
Navegación inferior (bottom navigation) fija y visible desde el Home: Inicio, Escanear QR, Lista de compras, Notificaciones, Perfil.
Accesibilidad: contraste suficiente entre color de fondo y texto, tamaños de letra legibles, y no depender únicamente del color para comunicar prioridad o estado (acompañar siempre con texto o ícono).
# 3. Mapa de navegación general
Flujo principal entre pantallas, para que quien construya la app (persona o IA) entienda cómo se conectan antes de generar cada una por separado:
Registro ↔ Inicio de sesión → (si el usuario no tiene grupo) Crear/Unirse a grupo familiar → Inicio (Home).
Inicio (Home) → Crear/Editar espacio | Detalle de espacio (QR) → Inventario del espacio → Agregar/Editar producto.
Inicio (Home) → Escanear QR → abre directamente el inventario del espacio escaneado.
Inicio (Home) → Lista de compras (también accesible desde la barra inferior en cualquier momento).
Inicio (Home) → Vista consolidada del inventario → Historial de cambios (desde el detalle de un producto).
Barra inferior → Notificaciones → al tocar una notificación, abre el inventario del espacio correspondiente.
Barra inferior → Perfil → datos del grupo familiar, miembros, salir del grupo, cerrar sesión.
# 4. Pantallas de la aplicación
## Pantalla 1. Registro de usuario
Objetivo: Permitir que una persona nueva cree una cuenta para poder usar la aplicación.
Requerimientos relacionados: RF01
### Campos y elementos
### Acciones que puede realizar el usuario
Botón "Crear cuenta": valida los campos y, si todo es correcto, crea el usuario y lo lleva a la Pantalla 3 (Crear/Unirse a grupo familiar).
Enlace "¿Ya tienes cuenta? Inicia sesión": lleva a la Pantalla 2.
### Validaciones y reglas de negocio
Si el correo ya existe, mostrar mensaje claro: "Este correo ya está registrado, inicia sesión."
Si las contraseñas no coinciden, marcar el campo en rojo con el mensaje correspondiente antes de intentar enviar el formulario.
No permitir enviar el formulario con campos vacíos.
### Navegación
Al registrarse exitosamente → Pantalla 3 (Crear/Unirse a grupo familiar). Si cancela → Pantalla 2 (Inicio de sesión).
## Pantalla 2. Inicio de sesión
Objetivo: Permitir que un usuario ya registrado acceda a su cuenta y, desde ahí, a su grupo familiar.
Requerimientos relacionados: RF01
### Campos y elementos
### Acciones que puede realizar el usuario
Botón "Iniciar sesión": valida credenciales.
Enlace "¿No tienes cuenta? Regístrate": lleva a la Pantalla 1.
(Opcional) enlace "¿Olvidaste tu contraseña?".
### Validaciones y reglas de negocio
Si las credenciales son incorrectas, mostrar un único mensaje genérico ("Correo o contraseña incorrectos") sin indicar cuál de los dos falló, por seguridad.
### Navegación
Si el usuario ya pertenece a un grupo familiar → Pantalla 4 (Inicio/Home). Si no pertenece a ningún grupo → Pantalla 3 (Crear/Unirse a grupo familiar).
Nota: Este es el mismo comportamiento que debe darse justo después del registro exitoso: la app siempre revisa primero si el usuario tiene un grupo antes de mostrarle el Home.
## Pantalla 3. Crear o unirse a un grupo familiar
Objetivo: Es el paso obligatorio antes de usar la app: el usuario debe crear un grupo familiar nuevo o unirse a uno existente con un código. Se recomienda mostrarla como dos pestañas u opciones ("Crear grupo" / "Unirme con código").
Requerimientos relacionados: RF02, RF03
### Campos y elementos
### Qué debe mostrar la pantalla
En la pestaña "Crear grupo", tras guardar, el código único generado en un formato grande y fácil de copiar/compartir (botón "Compartir código").
### Acciones que puede realizar el usuario
Botón "Crear grupo": genera el código único de acceso y crea el grupo.
Botón "Unirme": valida el código ingresado y vincula al usuario a ese grupo.
### Validaciones y reglas de negocio
Código inválido o inexistente → mensaje de error claro ("Código no válido, verifícalo con un integrante de tu hogar").
El código de un grupo debe ser único en todo el sistema.
### Navegación
Al crear o unirse exitosamente → Pantalla 4 (Inicio/Home).
## Pantalla 4. Inicio / Home (lista de espacios del hogar)
Objetivo: Pantalla principal tras iniciar sesión: muestra los espacios del hogar como tarjetas y es el punto de partida hacia el resto de la app.
Requerimientos relacionados: RF05, RF17
### Qué debe mostrar la pantalla
Una tarjeta por cada espacio del hogar, con su nombre, su color distintivo y un contador de productos en estado "mínimo" o "agotado" (badge rojo/amarillo si aplica).
Estado vacío si el grupo aún no tiene espacios creados, con botón para crear el primero.
Barra de navegación inferior fija: Inicio, Escanear QR, Lista de compras, Notificaciones, Perfil.
### Acciones que puede realizar el usuario
Tocar una tarjeta de espacio → abre la Pantalla 8 (Inventario de ese espacio).
Botón flotante "+" → abre la Pantalla 5 (Crear espacio).
Acceso (botón o ícono en la parte superior) a la Pantalla 11 (Vista consolidada del inventario).
### Navegación
Tarjeta de espacio → Inventario del espacio. Botón "+" → Crear espacio. Barra inferior → Escanear QR / Lista de compras / Notificaciones / Perfil.
## Pantalla 5. Crear o editar espacio del hogar
Objetivo: Permitir definir una zona física del hogar (cocina, baño, lavandería, etc.) con su propio inventario y su propio código QR.
Requerimientos relacionados: RF05, RF06
### Campos y elementos
### Acciones que puede realizar el usuario
Botón "Guardar": crea o actualiza el espacio; si es nuevo, genera automáticamente su código QR.
Botón "Eliminar espacio" (solo en modo edición): pide confirmación antes de borrar el espacio y su inventario asociado.
### Validaciones y reglas de negocio
El nombre no puede quedar vacío ni duplicar exactamente el nombre de otro espacio del mismo grupo.
Eliminar un espacio debe advertir explícitamente que también se eliminará su inventario.
### Navegación
Al guardar → Pantalla 6 (Detalle de espacio / QR). Al cancelar o eliminar → Pantalla 4 (Home).
## Pantalla 6. Detalle del espacio y código QR
Objetivo: Mostrar el código QR generado para un espacio y permitir imprimirlo/exportarlo para pegarlo físicamente en el hogar.
Requerimientos relacionados: RF06, RF19
### Qué debe mostrar la pantalla
El código QR en tamaño grande, sobre el color del espacio, junto con el nombre del espacio (para que quien lo escanee o lo vea sepa a qué zona pertenece).
### Acciones que puede realizar el usuario
Botón "Descargar / Imprimir QR": exporta el código en un formato listo para imprimir y pegar (RF19).
Botón "Ver inventario": abre la Pantalla 8.
Botón "Editar espacio": vuelve a la Pantalla 5 con los datos precargados.
### Navegación
"Ver inventario" → Pantalla 8. "Editar" → Pantalla 5.
## Pantalla 7. Escanear código QR
Objetivo: Dar acceso rápido (menos de 2 segundos) al inventario de un espacio escaneando su QR físico, sin tener que navegar manualmente por el Home.
Requerimientos relacionados: RF07
### Qué debe mostrar la pantalla
Vista de cámara en vivo con un marco/guía de escaneo centrado.
### Acciones que puede realizar el usuario
Al detectar un QR válido del grupo familiar del usuario, navega automáticamente al inventario de ese espacio.
Botón o enlace "Elegir espacio manualmente": alternativa para quien no puede o no quiere escanear (mitiga el riesgo de baja adopción del QR).
### Validaciones y reglas de negocio
QR inválido o de otro grupo familiar → mensaje de error ("Este código QR no pertenece a tu hogar") y permanece en la pantalla de escaneo.
### Navegación
Escaneo válido → Pantalla 8 (Inventario del espacio escaneado). "Elegir manualmente" → Pantalla 4 (Home).
## Pantalla 8. Inventario de un espacio
Objetivo: Ver y gestionar los productos de un espacio específico: registrar, ajustar cantidades, priorizar y eliminar.
Requerimientos relacionados: RF08, RF09, RF10, RF11, RF18
### Qué debe mostrar la pantalla
Encabezado con el nombre y color del espacio.
Lista de productos; cada fila muestra nombre, cantidad actual con su unidad, una etiqueta de color según prioridad (alta/media/baja) y un indicador visual si está en cantidad mínima o agotado.
Barra de filtro/búsqueda por nombre, categoría o prioridad (RF18).
### Acciones que puede realizar el usuario
Botones rápidos "+" / "−" en cada producto para ajustar la cantidad sin abrir otra pantalla (cumple el límite de 3 toques, RNF03).
Tocar un producto → abre la Pantalla 9 (Editar producto) con más detalle.
Deslizar o botón de menú por producto → "Eliminar" (con confirmación).
Botón flotante "+" → abre la Pantalla 9 en modo "Agregar producto".
### Validaciones y reglas de negocio
La cantidad no puede bajar de 0 usando el botón "−".
Cuando la cantidad llega a la cantidad mínima definida, el producto se resalta automáticamente y se agrega a la Lista de compras (ver Pantalla 10) sin acción manual del usuario (RF12).
### Navegación
Producto → Editar producto. "+" flotante → Agregar producto.
## Pantalla 9. Agregar o editar producto
Objetivo: Capturar o modificar los datos de un producto dentro del inventario de un espacio.
Requerimientos relacionados: RF08, RF09, RF11
### Campos y elementos
### Acciones que puede realizar el usuario
Botón "Guardar": crea o actualiza el producto.
Botón "Eliminar" (solo en modo edición): pide confirmación (RF10).
### Validaciones y reglas de negocio
Cantidad mínima no puede ser mayor que un valor absurdo respecto a la cantidad actual sin advertir al usuario (p. ej. sugerir revisión si mínimo > cantidad actual, ya que eso dispara la alerta de inmediato).
Nombre y cantidad son obligatorios; unidad y cantidad mínima también.
### Navegación
Al guardar o eliminar → regresa a la Pantalla 8 (Inventario del espacio).
## Pantalla 10. Lista de compras
Objetivo: Centralizar los productos que hay que comprar, ya sea porque llegaron a su cantidad mínima automáticamente o porque el usuario los agregó a mano.
Requerimientos relacionados: RF12, RF13, RF14
### Qué debe mostrar la pantalla
Dos secciones o etiquetas por ítem: "Agregado automáticamente" (por mínimo alcanzado) y "Agregado manualmente".
Cada ítem muestra: nombre, cantidad deseada, espacio de origen (si viene del inventario) y una casilla de "Comprado".
### Acciones que puede realizar el usuario
Casilla "Comprado": al marcarla, el ítem se retira de la lista y su cantidad se actualiza automáticamente en el inventario del espacio correspondiente (RF14).
Botón "+" → formulario simple para agregar un artículo manual (nombre, cantidad deseada) que no necesariamente existe en el inventario (RF13).
### Validaciones y reglas de negocio
Un producto no puede aparecer duplicado en la lista si ya está presente por umbral mínimo; si el usuario lo agrega manualmente estando ya en la lista, se debe fusionar o advertir.
### Navegación
Accesible tanto desde el Home (barra inferior) como desde cualquier pantalla mediante la barra de navegación.
## Pantalla 11. Vista consolidada del inventario
Objetivo: Dar una vista de todos los productos de todos los espacios del hogar en una sola pantalla, con filtros.
Requerimientos relacionados: RF17, RF18
### Qué debe mostrar la pantalla
Listado de productos agrupado por espacio (o agrupable/desagrupable), mostrando para cada uno su cantidad, unidad y prioridad, igual que en el inventario individual.
### Acciones que puede realizar el usuario
Barra de búsqueda por nombre de producto.
Filtros combinables por espacio, categoría y prioridad (RF18).
Tocar un producto → abre la Pantalla 9 (Editar producto) para ese producto.
### Navegación
Accesible desde el botón/ícono en la Pantalla 4 (Home).
## Pantalla 12. Notificaciones
Objetivo: Mostrar el historial de alertas push relacionadas con productos que llegaron a su mínimo o se agotaron.
Requerimientos relacionados: RF16
### Qué debe mostrar la pantalla
Lista cronológica (más reciente arriba) de notificaciones, cada una con: nombre del producto, nombre del espacio, fecha/hora y un ícono según si está en mínimo o agotado.
### Acciones que puede realizar el usuario
Tocar una notificación → abre el inventario del espacio correspondiente, con el producto resaltado.
### Validaciones y reglas de negocio
Solo se genera una notificación por evento relevante (producto llega al mínimo o se agota); no se notifica por cada cambio menor de cantidad, para evitar fatiga de notificaciones.
### Navegación
Accesible desde la barra de navegación inferior en cualquier pantalla.
## Pantalla 13. Perfil y grupo familiar
Objetivo: Gestionar los datos del usuario y del grupo familiar: ver miembros, compartir el código de invitación, salir del grupo o cerrar sesión.
Requerimientos relacionados: RF04
### Qué debe mostrar la pantalla
Datos del usuario: nombre y correo.
Nombre del grupo familiar y su código de acceso (con botón "Copiar/Compartir").
Lista de integrantes actuales del grupo.
### Acciones que puede realizar el usuario
Botón "Salir del grupo familiar": pide confirmación explícita antes de ejecutar, ya que implica perder acceso al inventario del grupo (RF04).
Botón "Cerrar sesión".
### Navegación
Al salir del grupo → Pantalla 3 (Crear/Unirse a grupo familiar). Al cerrar sesión → Pantalla 2 (Inicio de sesión).
## Pantalla 14. Historial de cambios
Objetivo: Consultar quién hizo qué cambio en el inventario y cuándo (funcionalidad Could have, incluir si el tiempo del proyecto lo permite).
Requerimientos relacionados: RF20
### Qué debe mostrar la pantalla
Lista cronológica de eventos: usuario que hizo el cambio, tipo de acción (agregó, editó cantidad, eliminó), producto afectado, espacio y fecha/hora.
### Acciones que puede realizar el usuario
Filtrar por espacio o por integrante del grupo (opcional).
### Navegación
Accesible desde el detalle de un producto (Pantalla 9) o desde el Perfil.
## Pantalla 15. Indicador de modo sin conexión (transversal)
Objetivo: No es una pantalla completa, sino un componente (banner) que debe aparecer sobre cualquier pantalla cuando el dispositivo pierde conexión a internet.
Requerimientos relacionados: RNF02
### Qué debe mostrar la pantalla
Banner fijo, por ejemplo en la parte superior: "Sin conexión — mostrando el último inventario guardado".
Al recuperar la conexión, un mensaje breve y temporal: "Sincronizando cambios..." mientras se envían los cambios pendientes.
### Validaciones y reglas de negocio
Ningún cambio hecho sin conexión debe perderse: debe quedar en una cola local y sincronizarse automáticamente al reconectar (RNF02), reflejándose en los demás dispositivos en menos de 3 segundos una vez sincronizado (RNF01).
# 5. Cómo usar este documento con una IA
Sugerencia de flujo de trabajo para pedirle a una IA (de código, diseño o texto) que construya la interfaz pantalla por pantalla:
Comparte primero la sección 2 (Lineamientos generales) una sola vez, para que la IA mantenga consistencia visual entre pantallas.
Luego, para cada pantalla, copia su bloque completo (Pantalla N) de la sección 4 y pégalo como instrucción, indicando además si quieres el resultado en código (por ejemplo Flutter/React Native), en un mockup visual, o en texto descriptivo.
Si la IA te devuelve una interfaz que le falta algún campo, acción o validación, señala directamente qué punto del bloque no cumplió; esta estructura sirve también como checklist de revisión.
Guarda las respuestas aprobadas junto a este documento como referencia para futuras iteraciones o para el informe de pruebas de usabilidad (RNF03).

| Campo / elemento | Tipo | Obligatorio | Descripción / regla |
| --- | --- | --- | --- |
| Nombre completo | Texto | Sí | Se usará para identificar al usuario dentro del grupo familiar (p. ej. en el historial de cambios). |
| Correo electrónico | Texto (email) | Sí | Debe tener formato de correo válido; no puede estar ya registrado. |
| Contraseña | Texto (oculto) | Sí | Mínimo 8 caracteres; mostrar un botón para revelar/ocultar. |
| Confirmar contraseña | Texto (oculto) | Sí | Debe coincidir exactamente con el campo Contraseña. |

| Campo / elemento | Tipo | Obligatorio | Descripción / regla |
| --- | --- | --- | --- |
| Correo electrónico | Texto (email) | Sí | Debe coincidir con un usuario registrado. |
| Contraseña | Texto (oculto) | Sí | Se valida contra la almacenada de forma cifrada. |

| Campo / elemento | Tipo | Obligatorio | Descripción / regla |
| --- | --- | --- | --- |
| Nombre del grupo (pestaña Crear) | Texto | Sí | Nombre visible del hogar, p. ej. "Familia Pico". |
| Código de acceso (pestaña Unirme) | Texto/numérico corto | Sí | Código alfanumérico que el usuario recibió de otro integrante del grupo. |

| Campo / elemento | Tipo | Obligatorio | Descripción / regla |
| --- | --- | --- | --- |
| Nombre del espacio | Texto | Sí | P. ej. "Cocina", "Baño principal". |
| Color | Selector de color | Sí | Se usa como acento visual en tarjetas, encabezado del inventario y fondo del QR. |
| Ícono | Selector de ícono (opcional) | No | Ícono representativo del espacio, de una librería predefinida. |

| Campo / elemento | Tipo | Obligatorio | Descripción / regla |
| --- | --- | --- | --- |
| Nombre del producto | Texto | Sí | P. ej. "Papel higiénico". |
| Cantidad actual | Numérico | Sí | Cantidad disponible en este momento. |
| Unidad | Selector | Sí | P. ej. unidades, rollos, litros, kg — lista predefinida editable. |
| Cantidad mínima | Numérico | Sí | Umbral que dispara el envío automático a la lista de compras y la notificación. |
| Prioridad | Selector visual (Alta / Media / Baja) | No (por defecto Media) | Determina el color de la etiqueta en el listado y el orden en la lista de compras. |
