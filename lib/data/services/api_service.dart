import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/user_model.dart';

/// Servicio para manejar las llamadas a la API
class ApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Registrar un nuevo usuario
  static Future<TokenResponse> register({
    required String email,
    required String password,
    String? nombreCompleto,
  }) async {
    try {
      final userRegisterDto = UserRegisterDto(
        email: email,
        password: password,
        nombreCompleto: nombreCompleto,
      );

      final response = await http.post(
        Uri.parse('${AppConstants.authBaseUrl}/register'),
        headers: _headers,
        body: jsonEncode(userRegisterDto.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TokenResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al registrar usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Iniciar sesión de usuario
  static Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final userLoginDto = UserLoginDto(email: email, password: password);

      final response = await http.post(
        Uri.parse('${AppConstants.authBaseUrl}/login'),
        headers: _headers,
        body: jsonEncode(userLoginDto.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return TokenResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Cerrar sesión
  static Future<void> logout(String accessToken) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $accessToken'};

      final response = await http.post(
        Uri.parse('${AppConstants.authBaseUrl}/logout'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al cerrar sesión');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener perfil del usuario actual
  static Future<PerfilModel> getUserProfile(String accessToken) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $accessToken'};

      final response = await http.get(
        Uri.parse('${AppConstants.authBaseUrl}/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return PerfilModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Verificar si el token es válido
  static Future<Map<String, dynamic>> verifyToken(String accessToken) async {
    try {
      final headers = {..._headers, 'Authorization': 'Bearer $accessToken'};

      final response = await http.get(
        Uri.parse('${AppConstants.authBaseUrl}/verify'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Token inválido');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
