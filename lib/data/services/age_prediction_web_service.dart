import 'package:tflite_web/tflite_web.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'age_prediction_interface.dart';

/// Implementación del servicio de predicción de edad para plataforma web
/// Utiliza tflite_web que es compatible con navegadores
class AgePredictionWebService implements AgePredictionInterface {
  TFLiteModel? _model;
  bool _isLoaded = false;

  @override
  bool get isLoaded => _isLoaded;

  /// Cargar el modelo TensorFlow Lite
  @override
  Future<void> loadModel() async {
    try {
      if (_isLoaded) return;

      debugPrint('🔄 [Web] Cargando modelo de predicción de edad...');

      // 1. Inicializar TFLite Web usando CDN
      await TFLiteWeb.initializeUsingCDN();
      debugPrint('✅ [Web] TFLite Web inicializado');

      // 2. Cargar el modelo desde assets
      final byteData = await rootBundle.load(
        'assets/modelsAI/modelo_prediccion_edad.tflite',
      );
      final bytes = byteData.buffer.asUint8List();

      // 3. Crear el modelo desde memoria
      _model = await TFLiteModel.fromMemory(bytes);

      _isLoaded = true;
      debugPrint('✅ [Web] Modelo de predicción de edad cargado exitosamente');

      // 4. Obtener información del modelo (si está disponible)
      try {
        final inputs = _model!.inputs;
        final outputs = _model!.outputs;
        debugPrint('📊 [Web] Información del modelo:');
        debugPrint('   Entradas: ${inputs.length}');
        if (inputs.isNotEmpty) {
          debugPrint('   Entrada shape: ${inputs.first.shape}');
          debugPrint('   Entrada type: ${inputs.first.dataType}');
        }
        debugPrint('   Salidas: ${outputs.length}');
        if (outputs.isNotEmpty) {
          debugPrint('   Salida shape: ${outputs.first.shape}');
          debugPrint('   Salida type: ${outputs.first.dataType}');
        }
      } catch (e) {
        debugPrint(
          '⚠️ [Web] No se pudo obtener información detallada del modelo: $e',
        );
      }
    } catch (e) {
      debugPrint('❌ [Web] Error al cargar el modelo de predicción de edad: $e');
      _isLoaded = false;
      rethrow;
    }
  }

  /// Predecir la edad en meses basada en el peso en kg
  @override
  Future<double?> predictAge(double pesoEnKg) async {
    try {
      // Asegurar que el modelo esté cargado
      if (!_isLoaded || _model == null) {
        await loadModel();
      }

      if (_model == null) {
        debugPrint('❌ [Web] Modelo no disponible para predicción');
        return null;
      }

      debugPrint(
        '🔮 [Web] Prediciendo edad para peso: ${pesoEnKg.toStringAsFixed(2)} kg',
      );

      // 1. Crear tensor de entrada
      final inputTensor = createTensor(
        [pesoEnKg], // Datos de entrada
        shape: [1], // Shape: [1] para un solo valor
        type: TFLiteDataType.float32, // Tipo de datos
      );

      debugPrint('📊 [Web] Tensor de entrada creado con datos: [$pesoEnKg]');

      // 2. Ejecutar predicción
      final outputs = _model!.predict(inputTensor);

      // 3. Extraer la predicción del resultado
      double edadPredichaEnMeses;

      if (outputs is Tensor) {
        // El resultado es un Tensor simple
        final data = outputs.dataSync();
        if (data.isNotEmpty) {
          edadPredichaEnMeses = (data.first as num).toDouble();
        } else {
          throw Exception('Tensor de salida vacío');
        }
      } else if (outputs is List) {
        // El resultado es una lista de tensores
        final firstOutput = outputs.first;
        if (firstOutput is Tensor) {
          final data = firstOutput.dataSync();
          edadPredichaEnMeses = (data.first as num).toDouble();
        } else {
          edadPredichaEnMeses = (firstOutput as num).toDouble();
        }
      } else {
        throw Exception(
          'Formato de salida no reconocido: ${outputs.runtimeType}',
        );
      }

      debugPrint(
        '📈 [Web] Edad predicha: ${edadPredichaEnMeses.toStringAsFixed(2)} meses',
      );

      // 4. Validar resultado (la edad debe ser positiva y razonable)
      if (edadPredichaEnMeses < 0) {
        debugPrint('⚠️ [Web] Predicción negativa, retornando 0');
        return 0.0;
      }

      if (edadPredichaEnMeses > 200) {
        debugPrint(
          '⚠️ [Web] Predicción muy alta (${edadPredichaEnMeses.toStringAsFixed(2)} meses), limitando a 200 meses',
        );
        return 200.0;
      }

      return edadPredichaEnMeses;
    } catch (e) {
      debugPrint('❌ [Web] Error en la predicción de edad: $e');
      return null;
    }
  }

  /// Liberar recursos del modelo
  @override
  void dispose() {
    try {
      // Nota: TFLiteModel no tiene un método dispose() explícito
      // Los recursos se liberan automáticamente por el garbage collector
      _model = null;
      _isLoaded = false;
      debugPrint('🧹 [Web] Referencias del modelo liberadas');
    } catch (e) {
      debugPrint('⚠️ [Web] Error al liberar recursos: $e');
    }
  }
}
