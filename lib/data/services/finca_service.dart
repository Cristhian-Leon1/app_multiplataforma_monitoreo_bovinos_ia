import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/finca_model.dart';

/// Servicio para manejar las operaciones de fincas con la API
class FincaService {
  static const String _fincaEndpoint = '${AppConstants.apiBaseUrl}/fincas';
  static const Duration _timeout = Duration(seconds: 30);

  static Map<String, String> _getHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'ngrok-skip-browser-warning':
          'true', // ✅ Evitar página de advertencia de ngrok
    };
  }

  /// Cliente HTTP que maneja redirecciones automáticamente
  static Future<http.Response> _makeRequest({
    required String method,
    required String url,
    required Map<String, String> headers,
    String? body,
  }) async {
    final client = http.Client();

    try {
      http.Response response;

      switch (method.toUpperCase()) {
        case 'POST':
          response = await client
              .post(Uri.parse(url), headers: headers, body: body)
              .timeout(_timeout);
          break;
        case 'GET':
          response = await client
              .get(Uri.parse(url), headers: headers)
              .timeout(_timeout);
          break;
        case 'PUT':
          response = await client
              .put(Uri.parse(url), headers: headers, body: body)
              .timeout(_timeout);
          break;
        case 'DELETE':
          response = await client
              .delete(Uri.parse(url), headers: headers)
              .timeout(_timeout);
          break;
        default:
          throw Exception('Método HTTP no soportado: $method');
      }

      // Si hay redirección (307, 308), seguir la redirección manualmente
      if (response.statusCode == 307 || response.statusCode == 308) {
        final location = response.headers['location'];
        if (location != null) {
          // Hacer la petición a la nueva URL
          switch (method.toUpperCase()) {
            case 'POST':
              response = await client
                  .post(Uri.parse(location), headers: headers, body: body)
                  .timeout(_timeout);
              break;
            case 'GET':
              response = await client
                  .get(Uri.parse(location), headers: headers)
                  .timeout(_timeout);
              break;
            case 'PUT':
              response = await client
                  .put(Uri.parse(location), headers: headers, body: body)
                  .timeout(_timeout);
              break;
            case 'DELETE':
              response = await client
                  .delete(Uri.parse(location), headers: headers)
                  .timeout(_timeout);
              break;
          }
        }
      }

      return response;
    } finally {
      client.close();
    }
  }

  /// Crear una nueva finca
  static Future<FincaModel> createFinca({
    required String token,
    required FincaCreateDto fincaData,
  }) async {
    try {
      final response = await _makeRequest(
        method: 'POST',
        url: '$_fincaEndpoint/',
        headers: _getHeaders(token),
        body: jsonEncode(fincaData.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('El servidor devolvió una respuesta vacía');
        }

        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return FincaModel.fromJson(responseData);
        } catch (e) {
          throw Exception(
            'Error al parsear la respuesta del servidor: ${e.toString()}',
          );
        }
      } else {
        // Intentar parsear el error si hay contenido
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            String errorMessage =
                'Error al crear la finca (${response.statusCode})';

            // Manejar el formato de error de FastAPI
            if (errorData is Map<String, dynamic>) {
              if (errorData.containsKey('detail')) {
                if (errorData['detail'] is String) {
                  errorMessage = errorData['detail'];
                } else if (errorData['detail'] is List) {
                  // Formato de validación de FastAPI
                  final details = errorData['detail'] as List;
                  if (details.isNotEmpty) {
                    final firstError = details.first;
                    if (firstError is Map<String, dynamic> &&
                        firstError.containsKey('msg')) {
                      errorMessage = firstError['msg'];
                    } else {
                      errorMessage =
                          'Error de validación: ${details.toString()}';
                    }
                  }
                }
              }
            }

            throw Exception(errorMessage);
          } catch (e) {
            if (e.toString().startsWith('Exception: ')) {
              rethrow; // Re-lanzar excepción ya formateada
            }
            throw Exception(
              'Error del servidor (${response.statusCode}): ${response.body}',
            );
          }
        } else {
          throw Exception(
            'Error del servidor (${response.statusCode}): Sin contenido',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Error de conexión: Verifica tu conexión a internet');
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener todas las fincas del usuario
  static Future<List<FincaModel>> getUserFincas({required String token}) async {
    try {
      final response = await _makeRequest(
        method: 'GET',
        url: '$_fincaEndpoint/',
        headers: _getHeaders(token),
      );
      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          return []; // Lista vacía si no hay contenido
        }

        try {
          final dynamic responseData = jsonDecode(response.body);
          if (responseData is List) {
            return responseData
                .map((json) => FincaModel.fromJson(json))
                .toList();
          } else {
            throw Exception('La respuesta no es una lista válida');
          }
        } catch (e) {
          throw Exception('Error al parsear las fincas: ${e.toString()}');
        }
      } else {
        // Manejar errores con el mismo formato que createFinca
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            String errorMessage =
                'Error al obtener las fincas (${response.statusCode})';

            if (errorData is Map<String, dynamic> &&
                errorData.containsKey('detail')) {
              if (errorData['detail'] is String) {
                errorMessage = errorData['detail'];
              } else if (errorData['detail'] is List) {
                final details = errorData['detail'] as List;
                if (details.isNotEmpty) {
                  final firstError = details.first;
                  if (firstError is Map<String, dynamic> &&
                      firstError.containsKey('msg')) {
                    errorMessage = firstError['msg'];
                  }
                }
              }
            }

            throw Exception(errorMessage);
          } catch (e) {
            if (e.toString().startsWith('Exception: ')) {
              rethrow;
            }
            throw Exception(
              'Error del servidor (${response.statusCode}): ${response.body}',
            );
          }
        } else {
          throw Exception(
            'Error del servidor (${response.statusCode}): Sin contenido',
          );
        }
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Error de conexión: Verifica tu conexión a internet');
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener una finca específica por ID
  static Future<FincaModel> getFincaById({
    required String token,
    required String fincaId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_fincaEndpoint/$fincaId'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return FincaModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Finca no encontrada');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualizar una finca
  static Future<FincaModel> updateFinca({
    required String token,
    required String fincaId,
    required FincaUpdateDto fincaData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_fincaEndpoint/$fincaId'),
        headers: _getHeaders(token),
        body: jsonEncode(fincaData.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return FincaModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar la finca');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Eliminar una finca
  static Future<void> deleteFinca({
    required String token,
    required String fincaId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$_fincaEndpoint/$fincaId'),
        headers: _getHeaders(token),
      );

      if (response.statusCode != 204) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar la finca');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener una finca con sus bovinos
  static Future<FincaModel> getFincaWithBovinos({
    required String token,
    required String fincaId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$_fincaEndpoint/$fincaId/with-bovinos'),
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return FincaModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Finca no encontrada');
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener finca completa con bovinos y sus últimas mediciones
  static Future<FincaWithBovinosAndMediciones> getFincaComplete({
    required String fincaId,
    required String token,
  }) async {
    try {
      final response = await _makeRequest(
        method: 'GET',
        url: '$_fincaEndpoint/$fincaId/complete',
        headers: _getHeaders(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return FincaWithBovinosAndMediciones.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Error al obtener datos completos de la finca',
        );
      }
    } catch (e) {
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
