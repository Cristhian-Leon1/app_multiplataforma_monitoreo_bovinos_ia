import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/constants.dart';

/// Servicio para manejar el almacenamiento local de datos
class StorageService {
  static SharedPreferences? _prefs;

  /// Inicializar SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Guardar token de acceso
  static Future<void> saveAccessToken(String token) async {
    await init();
    await _prefs!.setString(AppConstants.tokenKey, token);
  }

  /// Obtener token de acceso
  static Future<String?> getAccessToken() async {
    await init();
    return _prefs!.getString(AppConstants.tokenKey);
  }

  /// Guardar refresh token
  static Future<void> saveRefreshToken(String token) async {
    await init();
    await _prefs!.setString('${AppConstants.tokenKey}_refresh', token);
  }

  /// Obtener refresh token
  static Future<String?> getRefreshToken() async {
    await init();
    return _prefs!.getString('${AppConstants.tokenKey}_refresh');
  }

  /// Guardar datos del usuario
  static Future<void> saveUserData(UserModel user) async {
    await init();
    final userData = jsonEncode(user.toJson());
    await _prefs!.setString(AppConstants.userDataKey, userData);
  }

  /// Obtener datos del usuario
  static Future<UserModel?> getUserData() async {
    await init();
    final userData = _prefs!.getString(AppConstants.userDataKey);
    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      return UserModel.fromJson(userMap);
    }
    return null;
  }

  /// Guardar tiempo de expiración del token
  static Future<void> saveTokenExpiration(int expiresIn) async {
    await init();
    final expirationTime = DateTime.now().add(Duration(seconds: expiresIn));
    await _prefs!.setString(
      'token_expiration',
      expirationTime.toIso8601String(),
    );
  }

  /// Verificar si el token ha expirado
  static Future<bool> isTokenExpired() async {
    await init();
    final expirationString = _prefs!.getString('token_expiration');
    if (expirationString == null) return true;

    final expirationTime = DateTime.parse(expirationString);
    return DateTime.now().isAfter(expirationTime);
  }

  /// Limpiar todos los datos de autenticación
  static Future<void> clearAuthData() async {
    await init();
    await _prefs!.remove(AppConstants.tokenKey);
    await _prefs!.remove('${AppConstants.tokenKey}_refresh');
    await _prefs!.remove(AppConstants.userDataKey);
    await _prefs!.remove('token_expiration');
  }

  /// Verificar si hay una sesión activa
  static Future<bool> hasActiveSession() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final isExpired = await isTokenExpired();
    return !isExpired;
  }
}
