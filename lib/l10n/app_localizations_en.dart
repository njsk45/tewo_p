// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get welcomeTitle => 'Welcome to TeWo-P';

  @override
  String get setupSubtitle => 'Let\'s Setup Your App';

  @override
  String get existingBusiness => 'Existing Business';

  @override
  String get createBusiness => 'Create a Business';

  @override
  String get comingSoon => 'Coming Soon';
}
