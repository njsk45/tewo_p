// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get helloWorld => '¡Hola Mundo!';

  @override
  String get welcomeTitle => 'Bienvenido a TeWo-P';

  @override
  String get setupSubtitle => 'Configuremos tu App';

  @override
  String get existingBusiness => 'Negocio Existente';

  @override
  String get createBusiness => 'Crear un Negocio';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get languageDialogTitle => 'Idioma';
}
