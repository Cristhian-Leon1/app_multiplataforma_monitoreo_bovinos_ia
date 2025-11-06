import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';
import 'age_prediction_interface.dart';

/// Implementación del servicio de predicción de edad para plataformas móviles
/// Utiliza tflite_flutter que soporta dart:ffi
class AgePredictionMobileService implements AgePredictionInterface {
  Interpreter? _interpreter;
  bool _isLoaded = false;

  @override
  bool get isLoaded => _isLoaded;

  /// Cargar el modelo TensorFlow Lite
  @override
  Future<void> loadModel() async {
    try {
      if (_isLoaded) return;

      debugPrint('🔄 [Mobile] Cargando modelo de predicción de edad...');

      // Cargar el modelo desde assets
      _interpreter = await Interpreter.fromAsset(
        'assets/modelsAI/modelo_prediccion_edad.tflite',
      );

      if (_interpreter != null) {
        _isLoaded = true;
        debugPrint(
          '✅ [Mobile] Modelo de predicción de edad cargado exitosamente',
        );

        // Mostrar información del modelo para debugging
        final inputTensors = _interpreter!.getInputTensors();
        final outputTensors = _interpreter!.getOutputTensors();

        debugPrint('📊 [Mobile] Información del modelo:');
        debugPrint('   Entradas: ${inputTensors.length}');
        debugPrint('   Entrada shape: ${inputTensors.first.shape}');
        debugPrint('   Entrada type: ${inputTensors.first.type}');
        debugPrint('   Salidas: ${outputTensors.length}');
        debugPrint('   Salida shape: ${outputTensors.first.shape}');
        debugPrint('   Salida type: ${outputTensors.first.type}');
      } else {
        throw Exception('No se pudo inicializar el intérprete');
      }
    } catch (e) {
      debugPrint(
        '❌ [Mobile] Error al cargar el modelo de predicción de edad: $e',
      );
      _isLoaded = false;
      rethrow;
    }
  }

  /// Predecir la edad en meses basada en el peso en kg
  @override
  Future<double?> predictAge(double pesoEnKg) async {
    try {
      // Asegurar que el modelo esté cargado
      if (!_isLoaded) {
        await loadModel();
      }

      if (_interpreter == null) {
        debugPrint(
          '❌ [Mobile] Intérprete no disponible para predicción de edad',
        );
        return null;
      }

      debugPrint(
        '🔮 [Mobile] Prediciendo edad para peso: ${pesoEnKg.toStringAsFixed(2)} kg',
      );

      // Preparar entrada: Crear tensor de entrada compatible
      // Basado en tu modelo: shape=(1,) -> [peso]
      var inputData = <double>[pesoEnKg];
      var input = [inputData];

      // Preparar salida: El modelo devuelve shape [1, 1]
      var output = List<List<double>>.generate(
        1,
        (_) => List<double>.filled(1, 0.0),
      );

      // Ejecutar inferencia
      _interpreter!.run(input, output);

      // Extraer la predicción
      final edadPredichaEnMeses = output[0][0];

      debugPrint(
        '📈 [Mobile] Edad predicha: ${edadPredichaEnMeses.toStringAsFixed(2)} meses',
      );

      // Validar resultado (la edad debe ser positiva y razonable)
      if (edadPredichaEnMeses < 0) {
        debugPrint('⚠️ [Mobile] Predicción negativa, retornando 0');
        return 0.0;
      }

      if (edadPredichaEnMeses > 200) {
        debugPrint(
          '⚠️ [Mobile] Predicción muy alta (${edadPredichaEnMeses.toStringAsFixed(2)} meses), limitando a 200 meses',
        );
        return 200.0;
      }

      return edadPredichaEnMeses;
    } catch (e) {
      debugPrint('❌ [Mobile] Error en la predicción de edad: $e');
      return null;
    }
  }

  /// Liberar recursos del modelo
  @override
  void dispose() {
    try {
      _interpreter?.close();
      _interpreter = null;
      _isLoaded = false;
      debugPrint('🧹 [Mobile] Recursos del modelo liberados');
    } catch (e) {
      debugPrint('⚠️ [Mobile] Error al liberar recursos: $e');
    }
  }
}
