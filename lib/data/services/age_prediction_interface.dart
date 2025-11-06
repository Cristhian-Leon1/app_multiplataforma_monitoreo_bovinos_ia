/// Interfaz común para el servicio de predicción de edad
/// Permite implementaciones diferentes para móvil y web
abstract class AgePredictionInterface {
  /// Cargar el modelo TensorFlow Lite
  Future<void> loadModel();

  /// Predecir la edad en meses basada en el peso en kg
  Future<double?> predictAge(double pesoEnKg);

  /// Verificar si el modelo está cargado
  bool get isLoaded;

  /// Liberar recursos del modelo
  void dispose();
}
