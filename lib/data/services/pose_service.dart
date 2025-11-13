import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/pose_model.dart';

/// Servicio para el análisis de pose de bovinos
class PoseService {
  static const String _baseUrl = 'https://822504fdf8cc.ngrok-free.app';
  static const String _predictEndpoint = '/predict/';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning':
        'true', // ✅ Evitar página de advertencia de ngrok
  };

  /// Procesar imagen para envío a API (redimensiona al 25% - MISMO proceso para móvil y web)
  /// Acepta tanto File (móvil) como Uint8List (web)
  static Future<Uint8List> _processImage(dynamic imageData) async {
    try {
      Uint8List originalBytes;

      // Obtener bytes según el tipo de entrada
      if (kIsWeb && imageData is Uint8List) {
        originalBytes = imageData;
        print(
          'DEBUG WEB - Tamaño original antes procesamiento: ${originalBytes.length} bytes',
        );
      } else if (imageData is File) {
        originalBytes = await imageData.readAsBytes();
        print(
          'DEBUG MOBILE - Tamaño original antes procesamiento: ${originalBytes.length} bytes',
        );
      } else {
        throw Exception('Tipo de imagen no soportado');
      }

      // Decodificar la imagen
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) {
        throw Exception('No se pudo decodificar la imagen');
      }

      print(
        'DEBUG - Dimensiones originales: ${originalImage.width}x${originalImage.height}',
      );

      // MISMO PROCESO para ambas plataformas (igual que móvil Android)
      double scaleFactor = 0.25; // 25% para ambas plataformas
      int quality = 85; // Misma calidad para ambas plataformas

      // Calcular nuevas dimensiones (25% del tamaño original)
      final newWidth = (originalImage.width * scaleFactor).round();
      final newHeight = (originalImage.height * scaleFactor).round();

      print(
        'DEBUG - Nuevas dimensiones: ${newWidth}x${newHeight} (factor: $scaleFactor)',
      );

      // Redimensionar la imagen
      final resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Convertir de vuelta a bytes (formato JPEG para reducir tamaño)
      final resizedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: quality),
      );

      print(
        'DEBUG - Tamaño final después procesamiento: ${resizedBytes.length} bytes (calidad: $quality)',
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
      return resizedBytes;
    } catch (e) {
      throw Exception('Error al procesar imagen: $e');
    }
  }

  /// Analizar pose de una imagen
  /// Acepta tanto File (móvil) como Uint8List (web)
  static Future<(PosePredictionResponse, Uint8List)> analyzePose(
    dynamic imageData,
  ) async {
    final stopwatch = Stopwatch()..start();
    print('DEBUG - Iniciando análisis de pose...');

    try {
      // Procesar la imagen
      print('DEBUG - Procesando imagen...');
      final imageBytes = await _processImage(imageData);

      // Convertir a base64 puro (sin prefijo - formato que funciona con la API)
      print('DEBUG - Convirtiendo a base64...');
      final base64Pure = base64Encode(imageBytes);

      // Validación rápida del base64
      if (base64Pure.isEmpty) {
        throw Exception('Error: Base64 vacío');
      }

      print('DEBUG - Tamaño base64: ${base64Pure.length} caracteres');

      // Crear el request con base64 puro
      final request = PoseAnalysisRequest(image: base64Pure);

      // Hacer la petición HTTP
      print('DEBUG - Enviando petición HTTP...');
      final response = await _makeRequest(request);

      stopwatch.stop();
      print(
        'DEBUG - Análisis completado en ${stopwatch.elapsedMilliseconds}ms',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final prediction = PosePredictionResponse.fromJson(responseData);

        // Devolver tanto la predicción como la imagen redimensionada
        return (prediction, imageBytes);
      } else if (response.statusCode == 400) {
        throw Exception('Error 400 - Datos inválidos: ${response.body}');
      } else {
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
