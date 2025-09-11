import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/pose_model.dart';

/// Servicio para el análisis de pose de bovinos
class PoseService {
  static const String _baseUrl = 'https://b1a6a03b000f.ngrok-free.app';
  static const String _predictEndpoint = '/predict/';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Procesar imagen para envío a API (redimensiona al 25%)
  static Future<Uint8List> _processImage(File imageFile) async {
    try {
      // Leer los bytes de la imagen original
      final originalBytes = await imageFile.readAsBytes();

      // Decodificar la imagen
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      // Calcular nuevas dimensiones (25% del tamaño original)
      final newWidth = (originalImage.width * 0.25).round();
      final newHeight = (originalImage.height * 0.25).round();

      // Redimensionar la imagen
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Convertir de vuelta a bytes (formato JPEG para reducir tamaño)
      final resizedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      // Validar que la imagen se codificó correctamente
      if (resizedBytes.isEmpty) {
        throw Exception('Error al codificar imagen redimensionada');
      }

      // Validación adicional: intentar decodificar el JPEG generado
      final validationImage = img.decodeImage(resizedBytes);
      if (validationImage == null) {
        throw Exception('La imagen codificada no es válida');
      }

      print(
        'Imagen redimensionada: ${originalImage.width}x${originalImage.height} -> ${newWidth}x${newHeight}',
      );
      print(
        'Tamaño original: ${originalBytes.length} bytes -> Redimensionada: ${resizedBytes.length} bytes',
      );
      print(
        'Validación: Imagen redimensionada es válida (${validationImage.width}x${validationImage.height})',
      );

      return resizedBytes;
    } catch (e) {
      throw Exception('Error al procesar imagen: $e');
    }
  }

  /// Analizar pose de una imagen
  static Future<(PosePredictionResponse, Uint8List)> analyzePose(
    File imageFile,
  ) async {
    try {
      // Procesar la imagen
      final imageBytes = await _processImage(imageFile);

      // Convertir a base64 puro (sin prefijo - formato que funciona con la API)
      final base64Pure = base64Encode(imageBytes);

      // Validación rápida del base64
      if (base64Pure.isEmpty) {
        throw Exception('Error: Base64 vacío');
      }

      // Crear el request con base64 puro
      final request = PoseAnalysisRequest(image: base64Pure);

      // Hacer la petición HTTP
      final response = await _makeRequest(request);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final prediction = PosePredictionResponse.fromJson(responseData);

        // Devolver tanto la predicción como la imagen redimensionada
        return (prediction, imageBytes);
      } else if (response.statusCode == 400) {
        print('❌ Error 400 - Datos inválidos: ${response.body}');
        throw Exception('Error 400 - Datos inválidos: ${response.body}');
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception(
          'Error en la API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('Error de conexión: Verifica tu conexión a internet');
      } else if (e is FormatException) {
        throw Exception('Error en el formato de respuesta de la API');
      } else {
        throw Exception('Error al analizar pose: $e');
      }
    }
  }

  /// Función auxiliar para hacer la petición HTTP
  static Future<http.Response> _makeRequest(PoseAnalysisRequest request) async {
    final requestBody = jsonEncode(request.toJson());

    return await http.post(
      Uri.parse('$_baseUrl$_predictEndpoint'),
      headers: _headers,
      body: requestBody,
    );
  }
}
