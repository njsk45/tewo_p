# TeWo-P
**TeWo-P** es un sistema de "Database Mask Software" diseñado para ejecutarse en varias plataformas y adaptarse fácilmente a las diferentes necesidades de los usuarios. Es una ambiciosa alternativa de código abierto a los sistemas POS tradicionales, con funcionalidades modernas y un diseño limpio y simple.

# OBJETIVOS
- **Multiplataforma y Multifuncional:** Un sistema POS accesible en cualquier dispositivo.
- **Base de Datos Híbrida:** Soporte para bases de datos locales y en la nube.
- **Licencia Flexible:**
  - **Open Source:** Versión gratuita para gestión básica de ventas e inventario.
  - **Premium:** Funcionalidades avanzadas para uso profesional.
- **Integración Versátil:** APIs para modelos de BD locales, remotos y en la nube.
- **Mejora Continua:** Actualizaciones periódicas de seguridad, funcionalidad y soporte.

# FUNCIONALIDADES BASE

### Módulos Principales
- **Usuarios:** Inicio de sesión, Registro, Cierre de sesión, Gestión de contraseñas.
- **Inventario:** Listar, Buscar, Agregar, Modificar y Eliminar productos.
- **Ventas:** Listar, Buscar, Agregar, Modificar y Eliminar registros de ventas.
- **Reportes:** Generar, Buscar y Gestionar reportes.
- **Configuración:** Preferencias del sistema y del usuario.

### Capacidades de la API
- **Escritorio:** Uso remoto completo para Administradores y Empleados.
- **Móvil:** Uso remoto con limitaciones específicas (ej. Solo inicio de sesión y ventas).

# ESTRUCTURA DEL PROYECTO
El código base está organizado en bibliotecas modulares:

- **app_desktop/**: Código núcleo para la aplicación de escritorio.
  - `ui_desktop.dart`: Interfaz de usuario para escritorio.
  - `setting_up.dart`: Configuración y establecimiento de la base de datos.
  - `aws_service.dart`: Implementación de AWS DynamoDB.
- **app_movil/**: Código núcleo para la aplicación móvil.
  - `ui_movil.dart`: Interfaz de usuario para móvil.
  - `db_connector.dart`: Lógica de conexión a base de datos remota para móvil.

# ¿CÓMO FUNCIONA EL CÓDIGO?

### Detección de Plataforma e Inicio
El punto de entrada es `lib/main.dart`, que verifica qué versión de la UI ejecutar (escritorio o móvil).
*Nota: Actualmente, el desarrollo está enfocado en la UI de Escritorio (`lib/app_desktop/ui_desktop.dart`). La UI Móvil no está activa.*

### Flujo de Inicialización en Escritorio
Cuando el script detecta el SO como sistema de escritorio, inicia una verificación para asegurar que existe un archivo de configuración (`setts.json`).

1. **Primera Ejecución (Sin Configuración):**
   - Si `setts.json` no existe, la función principal redirige al usuario a la Pantalla de Configuración (`lib/apis/setting_up.dart`) para configurar la gestión de la base de datos.
   - Actualmente, `lib/apis/setting_up.dart` soporta **AWS DynamoDB**.
   - El usuario debe ingresar las claves de la BD, presionar el **botón de prueba**, y finalmente guardar las claves (formato encriptado).
   - Cuando la configuración finaliza, `lib/app_desktop/ui_desktop.dart` inicia con la `LoginDynamoDBPage`.
   - *Nota: Por ahora, los usuarios inician sesión con credenciales predefinidas: `admin` `admin`.*

2. **Ejecución Estándar (Configuración Existe):**
   - Si `setts.json` existe, la app realiza una prueba de conexión.
   - **Prueba OK:** Abre la Página de Login. Después del login, inicia la página principal de `lib/app_desktop/ui_desktop.dart`.
   - **Prueba Fallida:** Envía inmediatamente al usuario a una Página de Advertencia (verificar conexión o llamar a soporte de BD).
     - *Si la conectividad se resuelve:* Inicia automáticamente la Página de Login.

### Características de la Interfaz Principal
Después de iniciar sesión, la UI de Escritorio (`lib/app_desktop/ui_desktop.dart`) presenta dos opciones principales:
- **Prueba de Conexión:** Prueba la conexión con la Base de Datos.
- **Parámetros:** Gestionar configuraciones. Actualmente se limita a elegir el tema de la aplicación (Oscuro o Claro).

### Monitoreo Continuo
El software realiza una verificación regular de problemas de conectividad (ej. problemas de Wi-Fi o Internet).
Si se desconecta, el software redirige inmediatamente a una página de advertencia hasta que la conexión se restablezca.

# SISTEMA DE ADAPTACIÓN DE NEGOCIO (PREFIJOS)
TeWo-P emplea un **Sistema de Prefijos** único para adaptar dinámicamente la interfaz de usuario y los conjuntos de herramientas disponibles según el tipo específico de negocio que utiliza el software. Esta lógica se controla principalmente mediante las variables `bussines_prefix` y `bussines_target` gestionadas en la configuración.

### ¿Cómo funciona?
- **Identificación:** Cuando la aplicación se carga, lee el prefijo asignado (por ejemplo, `phones_repair`).
- **Adaptación de la Interfaz:** Basado en este prefijo, el software decide qué módulos específicos cargar. Por ejemplo, un taller de reparación de teléfonos verá columnas de inventario y botones de operación diferentes en comparación con una tienda minorista estándar.
- **Escalabilidad:** Esto permite que el mismo software central impulse tipos de empresas muy diferentes (Tiendas, Talleres, Negocios genéricos) sin necesidad de bases de código separadas.

# HOJA DE RUTA Y SEGURIDAD

### Protocolos de Seguridad Mejorados
A medida que avanzamos en nuestras fases iniciales de desarrollo, estamos comprometidos con la implementación de medidas de seguridad robustas y de vanguardia. Si bien las claves de la base de datos se almacenan actualmente cifradas localmente, nuestra arquitectura futura transicionará hacia **protocolos serverless**. Esta evolución asegura que las credenciales sensibles se gestionen con el más alto nivel de seguridad, manteniendo sus datos protegidos a medida que escalamos.

### Plugins "Plan Principal" (Próximamente)
Estamos construyendo una plataforma que crece contigo. El próximo **Sistema de Plugins "Plan Principal"** revolucionará la forma en que interactúas con TeWo-P. Los usuarios pronto tendrán el poder de:
- **Crear** comportamientos y flujos de trabajo de interfaz personalizados.
- **Exportar** sus configuraciones únicas.
- **Compartir** sus innovaciones con la comunidad global.
Esta característica tiene como objetivo democratizar el desarrollo de soluciones POS, permitiendo que cada usuario contribuya a un ecosistema más versátil y potente.

### PLUGINS Structure (STILL Testing, coming soon)
Grocery Plugin
|
├── manifest.json  
|   └── store_name: "Grocery Store"
|   └── store_prefix: "grocery"
|   └── store_logo: "store_logo.png"
|   └── store_scripts: "grocery_ops","grocery_view"
|
├── frontend/
|   └── grocery_ops.dart       //this will be replaced by a functional plugin script later
|   └── grocery_view.dart      //this will be replaced by a functional plugin script later
|
├── backend/
|   └── grocery_lambda/
|       └── index.js
|       └── package.json
|
└── assets/
    └── store_logo.png

Licencia MIT (ver LICENSE)
