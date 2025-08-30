import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';
import 'app_localizations_guc.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('guc'),
  ];

  /// Nombre de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Monitoreo Bovinos IA'**
  String get appName;

  /// Mensaje de bienvenida
  ///
  /// In es, this message translates to:
  /// **'Bienvenido'**
  String get welcome;

  /// Título de la pantalla de login
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginTitle;

  /// Título de la pantalla de registro
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get registerTitle;

  /// Subtítulo de la pantalla de login
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus credenciales para continuar'**
  String get loginSubtitle;

  /// Subtítulo de la pantalla de registro
  ///
  /// In es, this message translates to:
  /// **'Llena los datos para crear tu cuenta'**
  String get registerSubtitle;

  /// Campo de correo electrónico
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// Campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// Campo de confirmar contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// Campo de nombre completo
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullName;

  /// Botón de iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get login;

  /// Botón de crear cuenta
  ///
  /// In es, this message translates to:
  /// **'Crear Cuenta'**
  String get register;

  /// Pregunta si no tiene cuenta
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get dontHaveAccount;

  /// Pregunta si ya tiene cuenta
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get alreadyHaveAccount;

  /// Enlace para crear cuenta
  ///
  /// In es, this message translates to:
  /// **'Crear una'**
  String get createOne;

  /// Enlace para iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signIn;

  /// Enlace de contraseña olvidada
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPassword;

  /// Título del diálogo de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Recuperar Contraseña'**
  String get resetPassword;

  /// Mensaje del diálogo de recuperar contraseña
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.'**
  String get resetPasswordMessage;

  /// Botón enviar
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get send;

  /// Botón cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// Mensaje de procesando
  ///
  /// In es, this message translates to:
  /// **'Procesando...'**
  String get processing;

  /// Descripción de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Gestiona tu ganado con inteligencia artificial'**
  String get appDescription;

  /// Título de monitoreo de bovinos
  ///
  /// In es, this message translates to:
  /// **'Monitoreo de Bovinos'**
  String get cattleMonitoring;

  /// Descripción de gestión
  ///
  /// In es, this message translates to:
  /// **'Gestiona y monitorea tu ganado con tecnología de IA'**
  String get manageDescription;

  /// Opción de identificar bovino
  ///
  /// In es, this message translates to:
  /// **'Identificar Bovino'**
  String get identifyCattle;

  /// Subtítulo de escanear con IA
  ///
  /// In es, this message translates to:
  /// **'Escanear con IA'**
  String get scanWithAI;

  /// Opción de estadísticas
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// Subtítulo de ver reportes
  ///
  /// In es, this message translates to:
  /// **'Ver reportes'**
  String get viewReports;

  /// Opción de mi ganado
  ///
  /// In es, this message translates to:
  /// **'Mi Ganado'**
  String get myCattle;

  /// Subtítulo de lista completa
  ///
  /// In es, this message translates to:
  /// **'Lista completa'**
  String get completeList;

  /// Opción de configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settings;

  /// Subtítulo de preferencias
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferences;

  /// Opción de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Confirmación de cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get logoutConfirm;

  /// Mensaje de función próximamente
  ///
  /// In es, this message translates to:
  /// **'Función próximamente'**
  String get comingSoon;

  /// Usuario por defecto
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get user;

  /// Mensaje de éxito
  ///
  /// In es, this message translates to:
  /// **'Éxito'**
  String get success;

  /// Mensaje de usuario creado con éxito
  ///
  /// In es, this message translates to:
  /// **'¡Usuario creado exitosamente!'**
  String get userCreatedSuccessfully;

  /// Mensaje indicando que puede iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Ahora puedes iniciar sesión con tus credenciales.'**
  String get nowCanLogin;

  /// Botón para continuar al formulario de login
  ///
  /// In es, this message translates to:
  /// **'Continuar al Login'**
  String get continueLogin;
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
      <String>['es', 'guc'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
    case 'guc':
      return AppLocalizationsGuc();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
