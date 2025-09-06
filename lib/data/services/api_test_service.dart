import 'package:http/http.dart' as http;

/// Función de prueba para verificar conectividad con la API
class ApiTestService {
  static Future<void> testApiConnection() async {
    try {
      print('=== INICIO TEST DE API ===');

      // Test básico de conectividad
      final response = await http
          .get(Uri.parse('https://ashajaaia.onrender.com/docs'))
          .timeout(Duration(seconds: 10));

      print('Status docs: ${response.statusCode}');
      print('Headers docs: ${response.headers}');

      // Test del endpoint de salud si existe
      try {
        final healthResponse = await http
            .get(Uri.parse('https://ashajaaia.onrender.com/api/v1/health'))
            .timeout(Duration(seconds: 10));

        print('Status health: ${healthResponse.statusCode}');
        print('Body health: ${healthResponse.body}');
      } catch (e) {
        print('Endpoint health no disponible: $e');
      }

      print('=== FIN TEST DE API ===');
    } catch (e) {
      print('ERROR EN TEST: $e');
    }
  }

  static Future<void> testFincaEndpoint(String token) async {
    try {
      print('=== INICIO TEST FINCA ENDPOINT ===');
      print('Token: ${token.substring(0, 10)}...');

      // Test GET fincas
      final response = await http
          .get(
            Uri.parse('https://ashajaaia.onrender.com/api/v1/fincas'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 30));

      print('GET Status: ${response.statusCode}');
      print('GET Headers: ${response.headers}');
      print('GET Body: ${response.body}');

      print('=== FIN TEST FINCA ENDPOINT ===');
    } catch (e) {
      print('ERROR EN TEST FINCA: $e');
    }
  }
}
