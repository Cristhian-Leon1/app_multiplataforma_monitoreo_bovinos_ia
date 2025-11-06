// Imports condicionales según la plataforma
import 'package:flutter/foundation.dart';
import 'age_prediction_interface.dart';

// Import condicional: usa mobile por defecto, web si está disponible dart:html
import 'age_prediction_platform_mobile.dart'
    if (dart.library.html) 'age_prediction_platform_web.dart';

/// Servicio principal para predecir la edad de bovinos basado en el peso
/// Utiliza la implementación apropiada según la plataforma (móvil/web)
class AgePredictionService {
  static AgePredictionService? _instance;
  late AgePredictionInterface _implementation;

  // Singleton pattern
  static AgePredictionService get instance {
    _instance ??= AgePredictionService._internal();
    return _instance!;
  }

  AgePredictionService._internal() {
    // Crear la implementación apropiada usando la función factory
    _implementation = createAgePredictionService();

    if (kIsWeb) {
      debugPrint('🌐 Inicializando AgePredictionService para Web');
    } else {
      debugPrint('📱 Inicializando AgePredictionService para Móvil');
    }
  }

  /// Cargar el modelo TensorFlow Lite
  Future<void> loadModel() async {
    await _implementation.loadModel();
  }

  /// Predecir la edad en meses basada en el peso en kg
  Future<double?> predictAge(double pesoEnKg) async {
    return await _implementation.predictAge(pesoEnKg);
  }

  /// Verificar si el modelo está cargado
  bool get isModelLoaded => _implementation.isLoaded;

  /// Liberar recursos del modelo
  void dispose() {
    _implementation.dispose();
  }
}
