class AppConstants {
  // Duración del splash screen
  static const int splashDuration = 5; // segundos

  // URLs de API
  static const String apiBaseUrl = 'https://ashajaaia.onrender.com/api/v1';
  static const String authBaseUrl = '$apiBaseUrl/auth';
  static const String imagesBaseUrl = '$apiBaseUrl/images';

  // Configuración de la aplicación
  static const String appName = 'Ashajaa AI';
  static const String appVersion = '1.0.0';

  // Assets
  static const String logoPath = 'assets/images/logo_transparente.png';

  // Configuración de autenticación
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Configuración de monitoreo
  static const int maxCattlePerFarm = 1000;
  static const int monitoringIntervalMinutes = 15;
}
