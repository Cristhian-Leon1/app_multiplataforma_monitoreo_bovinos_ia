// Stub para plataforma web - exporta el servicio web
export 'age_prediction_web_service.dart';

// Alias para compatibilidad con imports condicionales
import 'age_prediction_web_service.dart' as web;
import 'age_prediction_interface.dart';

// Re-exporta el servicio web como implementación por defecto
AgePredictionInterface createAgePredictionService() =>
    web.AgePredictionWebService();
