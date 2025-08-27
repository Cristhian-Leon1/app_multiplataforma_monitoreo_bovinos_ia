import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('es', ''));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Método para obtener traducciones
  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['es']![key]!;
  }

  // Traducciones
  static const Map<String, Map<String, String>> _localizedValues = {
    'es': {
      'appName': 'Monitoreo Bovinos IA',
      'welcome': 'Bienvenido',
      'loginTitle': 'Iniciar Sesión',
      'registerTitle': 'Crear Cuenta',
      'loginSubtitle': 'Ingresa tus credenciales para continuar',
      'registerSubtitle': 'Llena los datos para crear tu cuenta',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'confirmPassword': 'Confirmar contraseña',
      'fullName': 'Nombre completo',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'dontHaveAccount': '¿No tienes una cuenta? ',
      'alreadyHaveAccount': '¿Ya tienes una cuenta? ',
      'createOne': 'Regístrate',
      'signIn': 'Inicia Sesión',
      'forgotPassword': '¿Olvidaste tu contraseña?',
      'resetPassword': 'Recuperar Contraseña',
      'resetPasswordMessage':
          'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
      'send': 'Enviar',
      'cancel': 'Cancelar',
      'processing': 'Procesando...',
      'appDescription': 'Gestiona tu ganado con inteligencia artificial',
      'cattleMonitoring': 'Monitoreo de Bovinos',
      'manageDescription':
          'Gestiona y monitorea tu ganado con tecnología de IA',
      'identifyCattle': 'Identificar Bovino',
      'scanWithAI': 'Escanear con IA',
      'statistics': 'Estadísticas',
      'viewReports': 'Ver reportes',
      'myCattle': 'Mi Ganado',
      'completeList': 'Lista completa',
      'settings': 'Configuración',
      'preferences': 'Preferencias',
      'logout': 'Cerrar Sesión',
      'logoutConfirm': '¿Estás seguro de que quieres cerrar sesión?',
      'comingSoon': 'Función próximamente',
      'user': 'Usuario',
      'slogan': 'Tecnología para el campo',
    },
    'guc': {
      'appName': 'Uuchon Atuma IA',
      'welcome': 'Yaatü',
      'loginTitle': 'Achajüin',
      'registerTitle': 'Ekaalain Süchukua',
      'loginSubtitle': 'Achiki wayuunaiki süchukua aainjaa',
      'registerSubtitle': 'Alüin süchukua ekaalain',
      'email': 'Correo',
      'password': 'Süchukua kachepa',
      'confirmPassword': 'Aküjütüin süchukua kachepa',
      'fullName': 'Süi wane',
      'login': 'Achajüin',
      'register': 'Ekaalain',
      'dontHaveAccount': '¿Nnojotsü süchukua? ',
      'alreadyHaveAccount': '¿Aisü süchukua? ',
      'createOne': 'Ekaalain wane',
      'signIn': 'Achajüin',
      'forgotPassword': '¿Ayuulirüin süchukua kachepa?',
      'resetPassword': 'Anaiküin Süchukua Kachepa',
      'resetPasswordMessage':
          'Alüin a\'correo nümaa anain süchukua kachepa anaiküin.',
      'send': 'Anain',
      'cancel': 'Ayuulüin',
      'processing': 'Ashajaain...',
      'appDescription': 'Ashajaain uuchon atuma IA',
      'cattleMonitoring': 'Uuchon Ekaa',
      'manageDescription': 'Ashajaain uuchon atuma IA',
      'identifyCattle': 'Ekaa Uuchon',
      'scanWithAI': 'Ekaa IA',
      'statistics': 'Akumajaa',
      'viewReports': 'Anaa akumajaa',
      'myCattle': 'Taya Uuchon',
      'completeList': 'Wane akumajaa',
      'settings': 'Ashajaain',
      'preferences': 'Anaa wayuu',
      'logout': 'Ayuulüin',
      'logoutConfirm': '¿Ayuulirüin süchukua?',
      'comingSoon': 'Kasachiki',
      'user': 'Wayuu',
      'slogan': 'Anainkat mmakat eekaluumuin',
    },
  };

  // Getters para facilitar el acceso
  String get appName => get('appName');
  String get welcome => get('welcome');
  String get loginTitle => get('loginTitle');
  String get registerTitle => get('registerTitle');
  String get loginSubtitle => get('loginSubtitle');
  String get registerSubtitle => get('registerSubtitle');
  String get email => get('email');
  String get password => get('password');
  String get confirmPassword => get('confirmPassword');
  String get fullName => get('fullName');
  String get login => get('login');
  String get register => get('register');
  String get dontHaveAccount => get('dontHaveAccount');
  String get alreadyHaveAccount => get('alreadyHaveAccount');
  String get createOne => get('createOne');
  String get signIn => get('signIn');
  String get forgotPassword => get('forgotPassword');
  String get resetPassword => get('resetPassword');
  String get resetPasswordMessage => get('resetPasswordMessage');
  String get send => get('send');
  String get cancel => get('cancel');
  String get processing => get('processing');
  String get appDescription => get('appDescription');
  String get cattleMonitoring => get('cattleMonitoring');
  String get manageDescription => get('manageDescription');
  String get identifyCattle => get('identifyCattle');
  String get scanWithAI => get('scanWithAI');
  String get statistics => get('statistics');
  String get viewReports => get('viewReports');
  String get myCattle => get('myCattle');
  String get completeList => get('completeList');
  String get settings => get('settings');
  String get preferences => get('preferences');
  String get logout => get('logout');
  String get logoutConfirm => get('logoutConfirm');
  String get comingSoon => get('comingSoon');
  String get user => get('user');
  String get slogan => get('slogan');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['es', 'guc'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
