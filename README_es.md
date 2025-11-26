# tewo_p

TeWo-P es un punto de venta Multi^2-PF (Multiplataforma-Multifuncional). En otras palabras, es un punto de venta que puede ser ejecutado en diferentes plataformas y adecuado de manera fácil para todo tipo de usuario.

Un proyecto ambicioso que pretende ser una alternativa a los puntos de venta tradicionales, con funcionalidades modernas y un diseño limpio y sencillo.

    OBJETIVOS
    
        - Ser un punto de venta Multi^2-PF (Multiplataforma-Multifuncional)

        - Ser un punto de venta accesible para el usuario en cualquier dispositivo

        - Tener una base de datos local y en la nube

        - Contar con una versión codigo abierto y de uso libre la cual permita la realización de ventas y la gestión de inventario con limitaciones, pero con funcionalidades básicas de un punto de venta tradicional.

        - Contar con una versión de uso premium la cual permita la realización de ventas y la gestión de inventario sin limitaciones, pero con funcionalidades avanzadas de un punto de venta tradicional.

        - Tener una versatilidad con apis que permitan la integración con modelos de DB locales, remotos y en la nube.

        - Actualizaciones periódicas de forma gratuita: De seguridad, de funcionalidades y de soporte.



FUNCIONALIDADES BASE

    Usuario:
    - Login
    - Registro
    - Cerrar sesión
    - Cambiar contraseña

    Inventario:
    - Listar productos
    - Buscar productos
    - Agregar productos
    - Modificar productos
    - Eliminar productos

    Ventas:
    - Listar ventas
    - Buscar ventas
    - Agregar ventas
    - Modificar ventas
    - Eliminar ventas

    Reportes:
    - Listar reportes
    - Buscar reportes
    - Agregar reportes
    - Modificar reportes
    - Eliminar reportes

    Configuración:
    - Listar configuración
    - Buscar configuración
    - Agregar configuración
    - Modificar configuración
    - Eliminar configuración

    APIs:
    - Uso remoto desde dispositivos de escritorio (Administrador y Empleado)
    - Uso remoto desde dispositivos de movil con limitaciones de Empleado (Solo iniciar sesion y ventas)
    - Uso remoto desde ddns a traves de ip dinámica (Se usará NO-IP)

    EXPLICATIVO DE lib
    - app_desktop: funciones base de la aplicación para escritorio

        * dblib.dart: la biblioteca de funciones base de la aplicación para escritorio

        * dblib.g.dart: Generación de código para la reflexión estática de dblib.dart

        * ui_desktop: interfaz de usuario para escritorio.


    - app_movil: funciones base de la aplicación para movil

        * db_connector.dart: la biblioteca de funciones de conexión a la base de datos remota de la aplicación para movil.
        
        * ui_movil: interfaz de usuario para movil.



Licencia MIT (veáse en LICENSE)
