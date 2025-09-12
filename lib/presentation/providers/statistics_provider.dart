import 'package:flutter/material.dart';
import '../../data/services/finca_service.dart';
import '../../data/services/api_test_service.dart';
import '../../data/models/finca_model.dart';

/// Provider para manejar el estado de la página de estadísticas
/// Gestiona las fincas del usuario y las estadísticas relacionadas
class StatisticsProvider extends ChangeNotifier {
  // Estado de la aplicación
  bool _isLoading = false;
  bool _isCreatingFinca = false;
  String? _errorMessage;
  bool _isDisposed = false;

  // Datos de fincas
  List<FincaModel> _fincas = [];
  FincaModel? _selectedFinca;
  bool _hasFincas = false;

  // Controller para el nombre de la nueva finca
  final TextEditingController _fincaNameController = TextEditingController();

  // Estadísticas calculadas
  int _totalBovinos = 0;
  Map<String, int> _totalRazas = {};
  Map<String, int> _totalSexos = {};
  Map<String, int> _totalRangosEdad = {};

  // Filtro y promedios por raza
  String? _selectedRazaFilter;
  Map<String, double> _pesoPromedioByRangoEdad = {};
  Map<String, double> _alturaPromedioByRangoEdad = {};
  List<BovinoWithLastMedicion> _bovinos = []; // Para almacenar los bovinos

  // Getters para el estado
  bool get isLoading => _isLoading;
  bool get isCreatingFinca => _isCreatingFinca;
  String? get errorMessage => _errorMessage;
  List<FincaModel> get fincas => _fincas;
  FincaModel? get selectedFinca => _selectedFinca;
  bool get hasFincas => _hasFincas;
  TextEditingController get fincaNameController => _fincaNameController;

  // Getters para estadísticas
  int get totalBovinos => _totalBovinos;
  Map<String, int> get totalRazas => _totalRazas;
  Map<String, int> get totalSexos => _totalSexos;
  Map<String, int> get totalRangosEdad => _totalRangosEdad;

  // Getters para filtro y promedios
  String? get selectedRazaFilter => _selectedRazaFilter;
  Map<String, double> get pesoPromedioByRangoEdad => _pesoPromedioByRangoEdad;
  Map<String, double> get alturaPromedioByRangoEdad =>
      _alturaPromedioByRangoEdad;
  List<String> get availableRazas => _totalRazas.keys.toList();

  /// Limpiar errores
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _safeNotifyListeners();
    }
  }

  /// Cambiar filtro de raza y recalcular promedios
  void setRazaFilter(String? raza) {
    if (_selectedRazaFilter != raza) {
      _selectedRazaFilter = raza;
      _calculatePromediosByRaza();
      _safeNotifyListeners();
    }
  }

  /// Método helper para notificar listeners de forma segura
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Establecer estado de carga
  void _setLoading(bool loading) {
    if (!_isDisposed) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  /// Establecer estado de creación de finca
  void _setCreatingFinca(bool creating) {
    if (!_isDisposed) {
      _isCreatingFinca = creating;
      notifyListeners();
    }
  }

  /// Establecer error
  void _setError(String error) {
    if (!_isDisposed) {
      _errorMessage = error;
      _isLoading = false;
      _isCreatingFinca = false;
      notifyListeners();
    }
  }

  /// Inicializar datos - verificar si el usuario tiene fincas
  Future<void> initializeData(String userToken) async {
    if (userToken.isEmpty) {
      _setError('No hay token de usuario válido');
      return;
    }

    _setLoading(true);
    clearError();

    try {
      // Obtener fincas del usuario
      final fincas = await FincaService.getUserFincas(token: userToken);

      _fincas = fincas;
      _hasFincas = fincas.isNotEmpty;

      if (_hasFincas) {
        // Si tiene fincas, seleccionar la primera por defecto
        _selectedFinca = fincas.first;
        await _loadFincaStatistics(userToken, _selectedFinca!.id);
      } else {
        // Si no tiene fincas, resetear estadísticas
        _resetStatistics();
      }

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar datos: ${e.toString()}');
    }
  }

  /// Crear una nueva finca
  Future<bool> createFinca(String userToken) async {
    if (userToken.isEmpty) {
      _setError('No hay token de usuario válido');
      return false;
    }

    final fincaName = _fincaNameController.text.trim();

    if (fincaName.isEmpty) {
      _setError('El nombre de la finca es obligatorio');
      return false;
    }

    if (fincaName.length < 3) {
      _setError('El nombre debe tener al menos 3 caracteres');
      return false;
    }

    // Mostrar loading inmediatamente después de las validaciones básicas
    _setCreatingFinca(true);
    clearError();

    try {
      // Test de conectividad antes de crear finca
      await ApiTestService.testFincaEndpoint(userToken);

      final fincaData = FincaCreateDto(nombre: fincaName);

      final newFinca = await FincaService.createFinca(
        token: userToken,
        fincaData: fincaData,
      );
      // Actualizar el estado
      _fincas.add(newFinca);
      _selectedFinca = newFinca;
      _hasFincas = true;

      // Limpiar el formulario
      _fincaNameController.clear();

      // Cargar estadísticas de la nueva finca
      await _loadFincaStatistics(userToken, newFinca.id);

      _setCreatingFinca(false);
      return true;
    } catch (e) {
      _setCreatingFinca(false); // Resetear estado de loading en caso de error
      _setError('Error al crear la finca: ${e.toString()}');
      return false;
    }
  }

  /// Cambiar finca seleccionada
  Future<void> selectFinca(String userToken, FincaModel finca) async {
    if (_selectedFinca?.id == finca.id) return;

    _selectedFinca = finca;
    _safeNotifyListeners();

    // Cargar estadísticas de la finca seleccionada
    await _loadFincaStatistics(userToken, finca.id);
  }

  /// Cargar estadísticas de una finca específica
  Future<void> _loadFincaStatistics(String userToken, String fincaId) async {
    try {
      // Resetear estadísticas antes de calcular nuevas
      _resetStatistics();

      // Obtener finca completa con bovinos y sus últimas mediciones
      final fincaCompleta = await FincaService.getFincaComplete(
        token: userToken,
        fincaId: fincaId,
      );

      // Calcular estadísticas usando los bovinos de la respuesta completa
      final bovinos = fincaCompleta.bovinos;
      _bovinos = bovinos; // Guardar bovinos para filtros
      _totalBovinos = bovinos.length;

      // Contar razas
      for (var bovino in bovinos) {
        final raza = bovino.raza ?? 'Desconocida';
        _totalRazas[raza] = (_totalRazas[raza] ?? 0) + 1;
      }

      // Contar sexos
      for (var bovino in bovinos) {
        final sexo = bovino.sexo ?? 'Desconocido';
        _totalSexos[sexo] = (_totalSexos[sexo] ?? 0) + 1;
      }

      // Contar por rangos de edad usando la última medición
      for (var bovino in bovinos) {
        if (bovino.ultimaMedicion != null &&
            bovino.ultimaMedicion!['edad_meses'] != null) {
          final edadMeses = bovino.ultimaMedicion!['edad_meses'] as num;
          final rangoEdad = _getRangoEdad(edadMeses.toInt());
          _totalRangosEdad[rangoEdad] = (_totalRangosEdad[rangoEdad] ?? 0) + 1;
        } else {
          // Si no hay medición o edad, contar como "Sin datos"
          _totalRangosEdad['Sin datos'] =
              (_totalRangosEdad['Sin datos'] ?? 0) + 1;
        }
      }

      print('Total bovinos: $_totalBovinos');
      print('Total por razas: $_totalRazas');
      print('Total por sexos: $_totalSexos');
      print('Total por rangos de edad: $_totalRangosEdad');

      _safeNotifyListeners();
    } catch (e) {
      // Si hay error al cargar estadísticas específicas, usar valores por defecto
      _resetStatistics();
      // No mostramos error aquí para no interferir con la UX principal
      print('Error cargando estadísticas: $e');
    }
  }

  /// Resetear estadísticas
  void _resetStatistics() {
    _totalBovinos = 0;
    _totalRazas = {};
    _totalSexos = {};
    _totalRangosEdad = {};
    _bovinos = [];
    _selectedRazaFilter = null;
    _pesoPromedioByRangoEdad = {};
    _alturaPromedioByRangoEdad = {};
  }

  /// Validar nombre de finca
  String? validateFincaName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre de la finca es obligatorio';
    }

    if (value.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }

    if (value.trim().length > 50) {
      return 'El nombre no puede tener más de 50 caracteres';
    }

    // Validar que no contenga caracteres especiales problemáticos
    final validPattern = RegExp(r'^[a-zA-Z0-9\s\-_\.]+$');
    if (!validPattern.hasMatch(value.trim())) {
      return 'El nombre solo puede contener letras, números, espacios, guiones y puntos';
    }

    return null;
  }

  /// Método para cuando cambia el texto del nombre de finca
  void onFincaNameChanged(String value) {
    clearError();
  }

  /// Limpiar todos los datos del provider
  void clearAllData() {
    _isLoading = false;
    _isCreatingFinca = false;
    _errorMessage = null;
    _fincas.clear();
    _selectedFinca = null;
    _hasFincas = false;
    _fincaNameController.clear();
    _resetStatistics();
    _safeNotifyListeners();
  }

  /// Eliminar la finca actual
  Future<bool> deleteFinca(String userToken) async {
    if (userToken.isEmpty || _selectedFinca == null) {
      _setError('No hay finca seleccionada o token válido');
      return false;
    }

    _setLoading(true);
    clearError();

    try {
      await FincaService.deleteFinca(
        token: userToken,
        fincaId: _selectedFinca!.id,
      );

      // Actualizar el estado local
      _fincas.removeWhere((finca) => finca.id == _selectedFinca!.id);
      _selectedFinca = null;
      _hasFincas = _fincas.isNotEmpty;

      if (!_hasFincas) {
        _resetStatistics();
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al eliminar la finca: ${e.toString()}');
      return false;
    }
  }

  /// Refrescar datos
  Future<void> refreshData(String userToken) async {
    await initializeData(userToken);
  }

  /// Determinar el rango de edad basado en los meses
  String _getRangoEdad(int edadMeses) {
    if (edadMeses >= 0 && edadMeses <= 6) {
      return '0-6 meses';
    } else if (edadMeses >= 7 && edadMeses <= 12) {
      return '7-12 meses';
    } else if (edadMeses >= 13 && edadMeses <= 24) {
      return '13-24 meses';
    } else if (edadMeses >= 25 && edadMeses <= 36) {
      return '25-36 meses';
    } else if (edadMeses >= 37 && edadMeses <= 48) {
      return '37-48 meses';
    } else if (edadMeses >= 49 && edadMeses <= 60) {
      return '49-60 meses';
    } else {
      return 'Mayores a 60 meses';
    }
  }

  /// Calcular promedios de peso y altura por rango de edad para la raza seleccionada
  void _calculatePromediosByRaza() {
    _pesoPromedioByRangoEdad.clear();
    _alturaPromedioByRangoEdad.clear();

    if (_selectedRazaFilter == null) return;

    // Filtrar bovinos por raza seleccionada
    final bovinosFiltrados = _bovinos
        .where((bovino) => bovino.raza == _selectedRazaFilter)
        .toList();

    // Agrupar por rango de edad
    Map<String, List<double>> pesosPorRango = {};
    Map<String, List<double>> alturasPorRango = {};

    for (var bovino in bovinosFiltrados) {
      if (bovino.ultimaMedicion != null) {
        final medicion = bovino.ultimaMedicion!;

        // Obtener edad y rango
        final edadMeses = medicion['edad_meses'];
        if (edadMeses != null) {
          final rangoEdad = _getRangoEdad((edadMeses as num).toInt());

          // Obtener peso
          final peso = medicion['peso_bascula_kg'];
          if (peso != null) {
            pesosPorRango.putIfAbsent(rangoEdad, () => []);
            pesosPorRango[rangoEdad]!.add((peso as num).toDouble());
          }

          // Obtener altura
          final altura = medicion['altura_cm'];
          if (altura != null) {
            alturasPorRango.putIfAbsent(rangoEdad, () => []);
            alturasPorRango[rangoEdad]!.add((altura as num).toDouble());
          }
        }
      }
    }

    // Calcular promedios
    for (var entry in pesosPorRango.entries) {
      final promedio = entry.value.reduce((a, b) => a + b) / entry.value.length;
      _pesoPromedioByRangoEdad[entry.key] = promedio;
    }

    for (var entry in alturasPorRango.entries) {
      final promedio = entry.value.reduce((a, b) => a + b) / entry.value.length;
      _alturaPromedioByRangoEdad[entry.key] = promedio;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _fincaNameController.dispose();
    super.dispose();
  }
}
