import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
abstract class AppLocalizations {
  AppLocalizations(String locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  String get helloWorld;
  String get login;
  String get password;
  String get username;
  String get signIn;
  String get testConnection;
  String get parameters;
  String get welcome;
  String get logout;
  String get areYouSureClose;
  String get closeLogOutWarning;
  String get yes;
  String get no;
  String get loggingOut;
  String get verifyingCredentials;
  String get sessionActiveWarning;
  String get errorUserAliasMissing;
  String get connectionFailed;
  String get connectionSuccessful;
  String error(String error);
  String get usersList;
  String get next;
  String get previous;
  String get searchUser;
  String get alias;
  String get name;
  String get role;
  String get email;
  String get curp;
  String get actions;
  String get edit;
  String get delete;
  String get deleteUserConfirm;
  String get userDeleted;
  String get availablePacks;
  String get noPacksFound;
  String get editUser;
  String get save;
  String get cancel;
  String get noUsersFound;
  String get errorFetchingUsers;
  String get setIdle;
  String get setActive;
  String get statusActive;
  String get statusIdle;
  String get sessionTimeout;
  String get createUser;
  String get createUserSuccess;
  String get fillAllFields;
  String get phone;
  String get creationDate;
  String get mainMenu;
  String get operations;
  String get stockInventory;
  String get managerTools;
  String get changePassword;
  String get newPassword;
  String get confirmPassword;
  String get rememberMe;
  String get welcomeTitle;
  String get connectExisting;
  String get createNew;
  String get setupTemplateTitle;
  String get setupTemplateSubTitle;
  String get grocery;
  String get restaurant;
  String get vehicleRental;
  String get phonesWorkshop;
  String get customBehavior;
  String get comingSoon;
  String get vehicleTypeTitle;
  String get vehicleType1;
  String get vehicleType2;
  String get vehicleType3;
  String get vehicleType4;
  String get vehicleType5;
  String get behaviorManager;
  String get searchPack;
  String get import;

  String get selectLanguage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'en':
    default:
      return AppLocalizationsEn();
  }
}

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';
  @override
  String get login => 'Login';
  @override
  String get password => 'Password';
  @override
  String get username => 'Username';
  @override
  String get signIn => 'Sign In';
  @override
  String get testConnection => 'Test Connection';
  @override
  String get parameters => 'Parameters';
  @override
  String get welcome => 'Welcome to TeWo-P';
  @override
  String get logout => 'Logout';
  @override
  String get areYouSureClose => 'Are you sure you want to continue?';
  @override
  String get closeLogOutWarning =>
      'This will log you out and set your session as inactive.';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
  @override
  String get loggingOut => 'Logging out...';
  @override
  String get verifyingCredentials => 'Verifying Credentials...';
  @override
  String get sessionActiveWarning =>
      'Session already active. Please log out from other devices.';
  @override
  String get errorUserAliasMissing => 'Error: User alias missing.';
  @override
  String get connectionFailed => 'Connection failed. Please try again.';
  @override
  String get connectionSuccessful => 'Connection Successful!';
  @override
  String error(String error) => 'Error: $error';

  @override
  String get usersList => 'Users List';
  @override
  String get next => 'Next';
  @override
  String get previous => 'Previous';
  @override
  String get searchUser => 'Search User...';
  @override
  String get alias => 'Alias';
  @override
  String get name => 'Name';
  @override
  String get role => 'Role';
  @override
  String get email => 'Email';
  @override
  String get curp => 'CURP';
  @override
  String get actions => 'Actions';
  @override
  String get edit => 'Edit';
  @override
  String get delete => 'Delete';
  @override
  String get deleteUserConfirm => 'Are you sure you want to delete this user?';
  @override
  String get userDeleted => 'User deleted successfully';
  @override
  String get editUser => 'Edit User';
  @override
  String get save => 'Save';
  @override
  String get cancel => 'Cancel';
  @override
  String get noUsersFound => 'No users found';
  @override
  String get errorFetchingUsers => 'Error fetching users';

  @override
  String get setIdle => 'Set Idle';
  @override
  String get setActive => 'Set Active';
  @override
  String get statusActive => 'Status: Active';
  @override
  String get statusIdle => 'Status: Idle';
  @override
  String get sessionTimeout => 'Session timed out due to inactivity.';
  @override
  String get createUser => 'Create User';
  @override
  String get createUserSuccess => 'User created successfully';
  @override
  String get fillAllFields => 'Please fill all fields';
  @override
  String get phone => 'Phone';
  @override
  String get creationDate => 'Creation Date';
  @override
  String get mainMenu => 'Main Menu';
  @override
  String get operations => 'Operations';
  @override
  String get stockInventory => 'Stock / Inventory';
  @override
  String get managerTools => 'Manager Tools';
  @override
  String get changePassword => 'Change Password';
  @override
  String get newPassword => 'New Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get rememberMe => 'Remember Me';
  @override
  String get welcomeTitle => 'Welcome to TeWo';
  @override
  String get connectExisting => 'Connect to Existing Business';
  @override
  String get createNew => 'Create New Business';
  @override
  String get setupTemplateTitle => 'Business Template';
  @override
  String get setupTemplateSubTitle => 'Recommended Behaviors';
  @override
  String get grocery => 'Grocery';
  @override
  String get restaurant => 'Restaurant';
  @override
  String get vehicleRental => 'Vehicles Rental';
  @override
  String get phonesWorkshop => 'Phones Workshop';
  @override
  String get customBehavior => 'More Behaviors';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get vehicleTypeTitle => 'Which kind of Vehicles will you Rent?';
  @override
  String get vehicleType1 => 'Cargo & Utility Vehicles';
  @override
  String get vehicleType2 => 'Urban Vehicles';
  @override
  String get vehicleType3 => 'Trips & Off-Road';
  @override
  String get vehicleType4 => 'Two-Wheeled Vehicles';
  @override
  String get vehicleType5 => 'General';
  @override
  String get behaviorManager => 'Behavior Manager';
  @override
  String get searchPack => 'Search Pack...';
  @override
  String get import => 'Import';
  @override
  String get availablePacks => 'Available Behavior Packs';
  @override
  String get noPacksFound => 'No packs found';
  @override
  String get selectLanguage => 'Select Language';
}

class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';
  @override
  String get login => 'Iniciar Sesión';
  @override
  String get password => 'Contraseña';
  @override
  String get username => 'Usuario';
  @override
  String get signIn => 'Ingresar';
  @override
  String get testConnection => 'Probar Conexión';
  @override
  String get parameters => 'Parámetros';
  @override
  String get welcome => 'Bienvenido a TeWo-P';
  @override
  String get logout => 'Cerrar Sesión';
  @override
  String get areYouSureClose => '¿Estás seguro de que deseas salir?';
  @override
  String get closeLogOutWarning =>
      'Esto cerrará tu sesión y la marcará como inactiva.';
  @override
  String get yes => 'Sí';
  @override
  String get no => 'No';
  @override
  String get loggingOut => 'Cerrando sesión...';
  @override
  String get verifyingCredentials => 'Verificando credenciales...';
  @override
  String get sessionActiveWarning =>
      'La sesión ya está activa. Por favor cierra sesión en otros dispositivos.';
  @override
  String get errorUserAliasMissing => 'Error: Falta el alias de usuario.';
  @override
  String get connectionFailed =>
      'Conexión fallida. Por favor intenta de nuevo.';
  @override
  String get connectionSuccessful => '¡Conexión Exitosa!';
  @override
  String error(String error) => 'Error: $error';

  @override
  String get usersList => 'Lista de Usuarios';
  @override
  String get next => 'Siguiente';
  @override
  String get previous => 'Anterior';
  @override
  String get searchUser => 'Buscar Usuario...';
  @override
  String get alias => 'Alias';
  @override
  String get name => 'Nombre';
  @override
  String get role => 'Rol';
  @override
  String get email => 'Correo';
  @override
  String get curp => 'CURP';
  @override
  String get actions => 'Acciones';
  @override
  String get edit => 'Editar';
  @override
  String get delete => 'Eliminar';
  @override
  String get deleteUserConfirm =>
      '¿Estás seguro de que quieres eliminar a este usuario?';
  @override
  String get userDeleted => 'Usuario eliminado exitosamente';
  @override
  String get editUser => 'Editar Usuario';
  @override
  String get save => 'Guardar';
  @override
  String get cancel => 'Cancelar';
  @override
  String get noUsersFound => 'No se encontraron usuarios';
  @override
  String get errorFetchingUsers => 'Error al obtener usuarios';

  @override
  String get setIdle => 'Establecer como Ausente';
  @override
  String get setActive => 'Establecer como Activo';
  @override
  String get statusActive => 'Estado: Activo';
  @override
  String get statusIdle => 'Estado: Ausente';
  @override
  String get sessionTimeout => 'La sesión caducó por inactividad.';
  @override
  String get createUser => 'Crear Usuario';
  @override
  String get createUserSuccess => 'Usuario creado exitosamente';
  @override
  String get fillAllFields => 'Por favor llene todos los campos';
  @override
  String get phone => 'Teléfono';
  @override
  String get creationDate => 'Fecha de Creación';
  @override
  String get mainMenu => 'Menú Principal';
  @override
  String get operations => 'Operaciones';
  @override
  String get stockInventory => 'Inventario';
  @override
  String get managerTools => 'Herramientas Administrativas';
  @override
  String get changePassword => 'Cambiar Contraseña';
  @override
  String get newPassword => 'Nueva Contraseña';
  @override
  String get confirmPassword => 'Confirmar Contraseña';
  @override
  String get rememberMe => 'Recordarme';
  @override
  String get welcomeTitle => 'Bienvenido a TeWo';
  @override
  String get connectExisting => 'Conectar a Negocio Existente';
  @override
  String get createNew => 'Crear Nuevo Negocio';
  @override
  String get setupTemplateTitle => 'Plantilla de Negocio';
  @override
  String get setupTemplateSubTitle => 'Comportamientos Recomendados';
  @override
  String get grocery => 'Supermercado';
  @override
  String get restaurant => 'Restaurante';
  @override
  String get vehicleRental => 'Renta de Vehículos';
  @override
  String get phonesWorkshop => 'Taller de Teléfonos';
  @override
  String get customBehavior => 'Más Comportamientos';
  @override
  String get comingSoon => 'Próximamente';
  @override
  String get vehicleTypeTitle => '¿Qué tipo de vehículos rentarás?';
  @override
  String get vehicleType1 => 'Vehículos de Carga y Utilidad';
  @override
  String get vehicleType2 => 'Vehículos Urbanos';
  @override
  String get vehicleType3 => 'Viajes y Todo Terrenos';
  @override
  String get vehicleType4 => 'Vehículos a Dos Ruedas';
  @override
  String get vehicleType5 => 'Vehículos Generales';
  @override
  String get behaviorManager => 'Gestor de Comportamientos';
  @override
  String get searchPack => 'Buscar Paquete...';
  @override
  String get import => 'Importar';
  @override
  String get availablePacks => 'Paquetes Disponibles';
  @override
  String get noPacksFound => 'No se encontraron paquetes';
  @override
  String get selectLanguage => 'Seleccionar Idioma';
}
