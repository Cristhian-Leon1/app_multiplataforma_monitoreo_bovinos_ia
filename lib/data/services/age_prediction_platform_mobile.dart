// Stub para plataforma móvil - exporta el servicio móvil
export 'age_prediction_mobile_service.dart';

// Alias para compatibilidad con imports condicionales
import 'age_prediction_mobile_service.dart' as mobile;
import 'age_prediction_interface.dart';

// Re-exporta el servicio móvil como implementación por defecto
AgePredictionInterface createAgePredictionService() =>
    mobile.AgePredictionMobileService();
