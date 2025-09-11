import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/medicion_model.dart';

/// Servicio para manejar operaciones de mediciones
class MedicionService {
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Crear una nueva medición
  static Future<MedicionModel> createMedicion({
    required String token,
    required MedicionCreateDto medicionData,
  }) async {
    try {
      final jsonData = medicionData.toJson();
      print('MedicionService - Enviando datos de medición:');
      print('MedicionService - JSON completo: ${jsonEncode(jsonData)}');

      print('MedicionService - Intentando crear medición...');

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/mediciones/'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(jsonData),
      );

      print('MedicionService - Create Response status: ${response.statusCode}');
      print('MedicionService - Create Response body: ${response.body}');

      if (response.statusCode == 201) {
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return MedicionModel.fromJson(responseData);
        } catch (e) {
          // Si hay problema deserializando la respuesta pero el status es 201,
          // asumimos que la medición se creó correctamente
          print(
            'MedicionService - Problema deserializando respuesta, pero status 201: $e',
          );
          // Creamos un modelo mock con los datos mínimos
          return MedicionModel(
            id: 'temp-id',
            bovinoId: medicionData.bovinoId,
            createdAt: DateTime.now(),
            fecha: medicionData.fecha,
            alturaCm: medicionData.alturaCm,
            lTorsoCm: medicionData.lTorsoCm,
            lOblicuaCm: medicionData.lOblicuaCm,
            lCaderaCm: medicionData.lCaderaCm,
            aCaderaCm: medicionData.aCaderaCm,
            edadMeses: medicionData.edadMeses,
            pesoBasculaKg: medicionData.pesoBasculaKg,
          );
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          print('MedicionService - Error response: $errorData');
          throw Exception(errorData['detail'] ?? 'Error al crear medición');
        } catch (e) {
          print('MedicionService - Error parsing error response: $e');
          throw Exception(
            'Error al crear medición - Status: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      print('MedicionService - Error en createMedicion: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener mediciones por bovino
  static Future<List<MedicionModel>> getMedicionesByBovino({
    required String token,
    required String bovinoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/mediciones/bovino/$bovinoId'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('MedicionService - Get Response status: ${response.statusCode}');
      print('MedicionService - Get Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        return responseData
            .map((medicion) => MedicionModel.fromJson(medicion))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener mediciones');
      }
    } catch (e) {
      print('MedicionService - Error en getMedicionesByBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener medición por ID
  static Future<MedicionModel> getMedicionById({
    required String token,
    required String medicionId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/mediciones/$medicionId'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print(
        'MedicionService - GetById Response status: ${response.statusCode}',
      );
      print('MedicionService - GetById Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return MedicionModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al obtener medición');
      }
    } catch (e) {
      print('MedicionService - Error en getMedicionById: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Actualizar medición
  static Future<MedicionModel> updateMedicion({
    required String token,
    required String medicionId,
    required MedicionUpdateDto medicionData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConstants.apiBaseUrl}/mediciones/$medicionId'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
        body: jsonEncode(medicionData.toJson()),
      );

      print('MedicionService - Update Response status: ${response.statusCode}');
      print('MedicionService - Update Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return MedicionModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al actualizar medición');
      }
    } catch (e) {
      print('MedicionService - Error en updateMedicion: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Eliminar medición
  static Future<bool> deleteMedicion({
    required String token,
    required String medicionId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.apiBaseUrl}/mediciones/$medicionId'),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print('MedicionService - Delete Response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Error al eliminar medición');
      }
    } catch (e) {
      print('MedicionService - Error en deleteMedicion: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  /// Obtener última medición de un bovino
  static Future<MedicionModel> getUltimaMedicionBovino({
    required String token,
    required String bovinoId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${AppConstants.apiBaseUrl}/mediciones/bovino/$bovinoId/ultima',
        ),
        headers: {..._headers, 'Authorization': 'Bearer $token'},
      );

      print(
        'MedicionService - GetUltima Response status: ${response.statusCode}',
      );
      print('MedicionService - GetUltima Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return MedicionModel.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Error al obtener última medición',
        );
      }
    } catch (e) {
      print('MedicionService - Error en getUltimaMedicionBovino: $e');
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
