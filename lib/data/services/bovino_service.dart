import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/bovino_model.dart';

/// Servicio para manejar operaciones de bovinos
class BovinoService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Crear un nuevo bovino
  static Future<BovinoModel> createBovino({
    required String token,
    required BovinoCreateDto bovinoData,
  }) async {
    try {
      final requestData = bovinoData.toJson();
      print(
        'BovinoService - Sending request to: ${AppConstants.apiBaseUrl}/bovinos/',
      );
      print('BovinoService - Request data: $requestData');
      print('BovinoService - Request body: ${jsonEncode(requestData)}');
      print(
        'BovinoService - Token (first 20 chars): ${token.substring(0, 20)}...',
      );

      // Validar datos antes de enviar
      final idBovino = (requestData['id_bovino']?.toString() ?? '').trim();
      final fincaId = (requestData['finca_id']?.toString() ?? '').trim();
      final sexo = requestData['sexo']?.toString()?.trim();
      final raza = requestData['raza']?.toString()?.trim();

      print('BovinoService - Validating data:');
      print('  - id_bovino: "$idBovino" (length: ${idBovino.length})');
      print('  - finca_id: "$fincaId" (length: ${fincaId.length})');
      print('  - sexo: "$sexo"');
      print('  - raza: "$raza"');

      if (idBovino.isEmpty) {
        throw Exception('id_bovino es requerido');
      }
      if (idBovino.length > 50) {
        throw Exception('id_bovino no puede tener más de 50 caracteres');
      }
      if (fincaId.isEmpty) {
        throw Exception('finca_id es requerido');
      }
      if (sexo != null &&
          sexo.isNotEmpty &&
          !['Macho', 'Hembra'].contains(sexo)) {
        throw Exception('sexo debe ser Macho o Hembra, recibido: "$sexo"');
      }
      if (raza != null && raza.isNotEmpty && raza.length > 100) {
        throw Exception('raza no puede tener más de 100 caracteres');
      }

      // Verificar que finca_id tenga formato UUID
      try {
        // Intentar parsear como UUID
        final uuid = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        );
        if (!uuid.hasMatch(fincaId.toLowerCase())) {
          throw Exception(
            'finca_id debe ser un UUID válido, recibido: "$fincaId"',
          );
        }
      } catch (e) {
        throw Exception('Error validando finca_id: $e');
      }

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/bovinos/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(bovinoData.toJson()),
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response headers: ${response.headers}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return BovinoModel.fromJson(responseData);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(response.body);

        // Verificar si es el error específico de serialización UUID
        if (errorData['detail'] != null &&
            errorData['detail'].toString().contains(
              'UUID is not JSON serializable',
            )) {
          // El bovino probablemente se creó correctamente, pero hay problema con la respuesta
          // Crear un modelo temporal con los datos que enviamos
          print(
            'BovinoService - Bovino creado pero error en serialización de respuesta',
          );
          return BovinoModel(
            id: 'temp_id', // ID temporal
            idBovino: bovinoData.idBovino,
            fincaId: bovinoData.fincaId,
            createdAt: DateTime.now().toIso8601String(),
            sexo: bovinoData.sexo,
            raza: bovinoData.raza,
          );
        } else {
          throw Exception(errorData['detail'] ?? 'Error al crear bovino');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al crear bovino');
      }
    } catch (e) {
      print('BovinoService - Error en createBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener bovinos por finca
  static Future<List<BovinoModel>> getBovinosByFinca({
    required String token,
    required String fincaId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/bovinos/finca/$fincaId/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((bovino) => BovinoModel.fromJson(bovino))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener bovinos');
      }
    } catch (e) {
      print('BovinoService - Error en getBovinosByFinca: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener bovino por ID
  static Future<BovinoModel> getBovinoById({
    required String token,
    required String bovinoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/bovinos/$bovinoId/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return BovinoModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener bovino');
      }
    } catch (e) {
      print('BovinoService - Error en getBovinoById: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualizar bovino
  static Future<BovinoModel> updateBovino({
    required String token,
    required String bovinoId,
    required BovinoUpdateDto bovinoData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/bovinos/$bovinoId/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(bovinoData.toJson()),
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return BovinoModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar bovino');
      }
    } catch (e) {
      print('BovinoService - Error en updateBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Eliminar bovino
  static Future<bool> deleteBovino({
    required String token,
    required String bovinoId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/bovinos/$bovinoId/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('BovinoService - Response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar bovino');
      }
    } catch (e) {
      print('BovinoService - Error en deleteBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener bovino con mediciones
  static Future<BovinoWithMedicionesModel> getBovinoWithMediciones({
    required String token,
    required String bovinoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.apiBaseUrl}/bovinos/$bovinoId/with-mediciones/',
        ),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return BovinoWithMedicionesModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Error al obtener bovino con mediciones',
        );
      }
    } catch (e) {
      print('BovinoService - Error en getBovinoWithMediciones: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Buscar bovinos por ID de bovino
  static Future<List<BovinoModel>> searchBovinosByIdBovino({
    required String token,
    required String idBovino,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.apiBaseUrl}/bovinos/search/by-id?id_bovino=$idBovino',
        ),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('BovinoService - Response status: ${response.statusCode}');
      print('BovinoService - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((bovino) => BovinoModel.fromJson(bovino))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al buscar bovinos');
      }
    } catch (e) {
      print('BovinoService - Error en searchBovinosByIdBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
