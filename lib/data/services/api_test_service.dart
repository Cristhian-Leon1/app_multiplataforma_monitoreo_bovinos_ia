import 'package:http/http.dart' as http;

/// Función de prueba para verificar conectividad con la API
class ApiTestService {
  static Future<void> testApiConnection() async {
    try {
      // Test básico de conectividad
      await http
          .get(Uri.parse('https://ashajaaia.onrender.com/docs'))
          .timeout(Duration(seconds: 10));

      // Test del endpoint de salud si existe
      try {
        await http
            .get(Uri.parse('https://ashajaaia.onrender.com/api/v1/health'))
            .timeout(Duration(seconds: 10));
      } catch (e) {
        // Endpoint health no disponible
      }
    } catch (e) {
      // Error en test
    }
  }

  static Future<void> testFincaEndpoint(String token) async {
    try {
      // Test GET fincas
      await http
          .get(
            Uri.parse('https://ashajaaia.onrender.com/api/v1/fincas'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 30));
    } catch (e) {
      // Error en test finca
    }
  }
}
