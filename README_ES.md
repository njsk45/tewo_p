# TeWo-P
**TeWo-P** es un sistema de Punto de Venta (POS) "Multi^2-PF" (Multiplataforma-Multifuncional) diseñado para ejecutarse en varias plataformas y adaptarse fácilmente a las diferentes necesidades de los usuarios. Es una ambiciosa alternativa de código abierto a los sistemas POS tradicionales, con funcionalidades modernas y un diseño limpio y simple.

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

Licencia MIT (ver LICENSE)
