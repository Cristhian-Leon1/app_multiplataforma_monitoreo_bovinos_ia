import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/user_model.dart';

/// Servicio para manejar las llamadas a la API
class ApiService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning':
        'true', // ✅ Evitar página de advertencia de ngrok
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

  /// Subir imagen de perfil
  static Future<ProfileImageUploadResponse> uploadProfileImage({
    required String token,
    required String imageBase64,
    required String userId, // UUID del usuario
    String? fileName,
  }) async {
    try {
      // El backend espera el formato completo: data:image/type;base64,{data}
      // Si no tiene el formato correcto, agregarlo
      String formattedBase64 = imageBase64;
      if (!imageBase64.startsWith('data:')) {
        formattedBase64 = 'data:image/jpeg;base64,$imageBase64';
      }

      final uploadRequest = ProfileImageUploadRequest(
        imageBase64: formattedBase64, // Usar formato completo
        userId: userId,
        fileName: fileName,
      );

      final response = await http.post(
        Uri.parse('${AppConstants.imagesBaseUrl}/upload-profile'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(uploadRequest.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return ProfileImageUploadResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage =
            errorData['detail'] ?? 'Error al subir imagen de perfil';
        throw Exception('Error HTTP ${response.statusCode}: $errorMessage');
      }
    } catch (e) {
      if (e.toString().contains('Error HTTP')) {
        rethrow; // Re-lanzar errores HTTP para mantener el mensaje específico
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
