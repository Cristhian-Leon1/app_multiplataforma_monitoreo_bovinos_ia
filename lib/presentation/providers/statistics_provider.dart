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
  int _bovinosSanos = 0;
  int _bovinosAlerta = 0;
  int _analisisRealizados = 0;

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
  int get bovinosSanos => _bovinosSanos;
  int get bovinosAlerta => _bovinosAlerta;
  int get analisisRealizados => _analisisRealizados;

  /// Limpiar errores
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
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
      print('DEBUG - Iniciando creación de finca: $fincaName');
      print('DEBUG - Token disponible: ${userToken.isNotEmpty}');
      print(
        'DEBUG - Token preview: ${userToken.length > 10 ? userToken.substring(0, 10) + "..." : userToken}',
      );

      // Test de conectividad antes de crear finca
      await ApiTestService.testFincaEndpoint(userToken);

      final fincaData = FincaCreateDto(nombre: fincaName);
      print('DEBUG - Datos a enviar: ${fincaData.toJson()}');

      final newFinca = await FincaService.createFinca(
        token: userToken,
        fincaData: fincaData,
      );

      print('DEBUG - Finca creada exitosamente: ${newFinca.toJson()}');

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
      print('DEBUG - Error al crear finca: $e');
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
      // Obtener finca con bovinos
      final fincaWithBovinos = await FincaService.getFincaWithBovinos(
        token: userToken,
        fincaId: fincaId,
      );

      // Calcular estadísticas
      final bovinos = fincaWithBovinos.bovinos ?? [];
      _totalBovinos = bovinos.length;

      // Por ahora, como no tenemos el campo de estado de salud,
      // usaremos valores simulados basados en los datos existentes
      _bovinosSanos = (_totalBovinos * 0.8).round(); // 80% sanos
      _bovinosAlerta = _totalBovinos - _bovinosSanos; // El resto en alerta
      _analisisRealizados =
          _totalBovinos; // Cada bovino registrado tiene al menos un análisis

      _safeNotifyListeners();
    } catch (e) {
      // Si hay error al cargar estadísticas específicas, usar valores por defecto
      _resetStatistics();
      // No mostramos error aquí para no interferir con la UX principal
    }
  }

  /// Resetear estadísticas
  void _resetStatistics() {
    _totalBovinos = 0;
    _bovinosSanos = 0;
    _bovinosAlerta = 0;
    _analisisRealizados = 0;
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

  @override
  void dispose() {
    _isDisposed = true;
    _fincaNameController.dispose();
    super.dispose();
  }
}
