import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/user_model.dart';

/// AuthProvider - Maneja todo el estado de autenticación de la aplicación
/// Siguiendo el principio de responsabilidad única (SRP)
class AuthProvider extends ChangeNotifier {
  // Estado de la aplicación
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  bool _isLoginMode = true; // true para login, false para registro
  String? _userToken;
  UserModel? _userData;
  bool _isInitialized =
      false; // Para controlar si ya se verificó la sesión almacenada

  // Controllers para persistencia de formularios
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _registerConfirmPasswordController =
      TextEditingController();

  // Constructor que inicializa automáticamente la sesión
  AuthProvider() {
    _initializeAuth();
  }

  // Getters para el estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoginMode => _isLoginMode;
  String? get userToken => _userToken;
  UserModel? get userData => _userData;
  bool get isInitialized => _isInitialized;

  // Getters para los controllers (persistencia de formularios)
  TextEditingController get loginEmailController => _loginEmailController;
  TextEditingController get loginPasswordController => _loginPasswordController;
  TextEditingController get registerNameController => _registerNameController;
  TextEditingController get registerEmailController => _registerEmailController;
  TextEditingController get registerPasswordController =>
      _registerPasswordController;
  TextEditingController get registerConfirmPasswordController =>
      _registerConfirmPasswordController;

  // Alternar entre modo login y registro
  void toggleAuthMode() {
    _isLoginMode = !_isLoginMode;
    _clearError();
    // Limpiar todos los campos cuando se cambia de modo
    _clearAllFields();
    notifyListeners();
  }

  // Método principal de login
  Future<bool> login() async {
    _setLoading(true);
    _clearError();

    try {
      final email = _loginEmailController.text.trim();
      final password = _loginPasswordController.text.trim();

      // Validaciones
      if (!_validateLoginInput(email, password)) {
        return false;
      }

      // Llamada real a la API
      final tokenResponse = await ApiService.login(
        email: email,
        password: password,
      );

      // Debug: Ver qué datos se están recibiendo
      // print('DEBUG - Usuario recibido: ${tokenResponse.user.toJson()}');
      // print('DEBUG - Perfil: ${tokenResponse.user.perfil?.toJson()}');

      // Guardar datos en storage local
      await StorageService.saveAccessToken(tokenResponse.accessToken);
      await StorageService.saveRefreshToken(tokenResponse.refreshToken);
      await StorageService.saveUserData(tokenResponse.user);
      await StorageService.saveTokenExpiration(tokenResponse.expiresIn);

      // Actualizar estado
      _setUserData(tokenResponse.user);
      _setToken(tokenResponse.accessToken);
      _isLoggedIn = true;

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Método principal de registro
  Future<bool> register() async {
    _setLoading(true);
    _clearError();

    try {
      final name = _registerNameController.text.trim();
      final email = _registerEmailController.text.trim();
      final password = _registerPasswordController.text.trim();
      final confirmPassword = _registerConfirmPasswordController.text.trim();

      // Validaciones
      if (!_validateRegisterInput(name, email, password, confirmPassword)) {
        return false;
      }

      // Llamada real a la API - solo validamos que sea exitosa
      await ApiService.register(
        email: email,
        password: password,
        nombreCompleto: name,
      );

      // NO auto-logueamos al usuario para permitir el flujo de confirmación
      // Solo registramos y retornamos éxito

      // Limpiar campos del formulario de registro
      _clearRegisterFields();

      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Inicialización automática de la sesión almacenada
  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);

      // Verificar si hay una sesión activa usando el método del StorageService
      final hasActiveSession = await StorageService.hasActiveSession();

      if (!hasActiveSession) {
        print('No hay sesión activa almacenada');
        return;
      }

      // Obtener datos de la sesión almacenada
      final storedToken = await StorageService.getAccessToken();
      final storedUserData = await StorageService.getUserData();

      if (storedToken != null && storedUserData != null) {
        try {
          // Verificar con el backend (ahora que está arreglado)
          await ApiService.verifyToken(storedToken);

          // Si llegamos aquí, el token es válido
          _userToken = storedToken;
          _userData = storedUserData;
          _isLoggedIn = true;
          print(
            '✅ Sesión restaurada exitosamente para: ${storedUserData.email}',
          );
        } catch (e) {
          print('❌ Error verificando token con backend: $e');
          // Token inválido o expirado, limpiar datos
          await _clearStoredAuthData();
          print('🧹 Sesión limpiada debido a token inválido');
        }
      } else {
        print('⚠️ Datos de sesión incompletos, limpiando...');
        await _clearStoredAuthData();
      }
    } catch (e) {
      print('💥 Error inicializando autenticación: $e');
      // En caso de error, limpiar datos para evitar estados inconsistentes
      try {
        await _clearStoredAuthData();
      } catch (clearError) {
        print('🚨 Error adicional limpiando datos: $clearError');
      }
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  // Método auxiliar para limpiar datos de autenticación almacenados
  Future<void> _clearStoredAuthData() async {
    await StorageService.clearAuthData();
    _isLoggedIn = false;
    _userToken = null;
    _userData = null;
  }

  // Cerrar sesión
  Future<void> logout() async {
    try {
      // Llamar a la API de logout si hay token
      if (_userToken != null) {
        await ApiService.logout(_userToken!);
      }
    } catch (e) {
      // Si falla el logout en el servidor, continuar con logout local
      print('Error al cerrar sesión en servidor: $e');
    } finally {
      // Limpiar datos locales
      await StorageService.clearAuthData();
      _isLoggedIn = false;
      _userToken = null;
      _userData = null;
      _clearError();
      notifyListeners();
    }
  }

  // Recuperar contraseña
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      if (!_isValidEmail(email)) {
        _setError('Por favor ingresa un correo válido');
        return false;
      }

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Implementar lógica real de recuperación
      return true;
    } catch (e) {
      _setError('Error al enviar correo de recuperación: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verificar estado de autenticación (para splash screen)
  Future<bool> checkAuthStatus() async {
    try {
      // Verificar si hay una sesión activa en storage
      final hasSession = await StorageService.hasActiveSession();
      if (!hasSession) {
        return false;
      }

      // Obtener token y datos del usuario
      final token = await StorageService.getAccessToken();
      final userData = await StorageService.getUserData();

      if (token != null && userData != null) {
        // Verificar token con el servidor
        try {
          await ApiService.verifyToken(token);

          // Si el token es válido, actualizar estado
          _userToken = token;
          _userData = userData;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        } catch (e) {
          // Si el token no es válido, limpiar datos
          await StorageService.clearAuthData();
          return false;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // Limpiar todos los formularios
  void clearAllForms() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
    _registerNameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
    _registerConfirmPasswordController.clear();
    _clearError();
  }

  // Método privado para limpiar campos al cambiar de modo
  void _clearAllFields() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
    _registerNameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
    _registerConfirmPasswordController.clear();
  }

  // Método privado para limpiar solo campos de registro
  void _clearRegisterFields() {
    _registerNameController.clear();
    _registerEmailController.clear();
    _registerPasswordController.clear();
    _registerConfirmPasswordController.clear();
  }

  // Actualizar datos del usuario
  void updateUserData(UserModel newData) {
    _userData = newData;
    notifyListeners();
  }

  // === MÉTODOS PRIVADOS ===

  // Validación de entrada para login
  bool _validateLoginInput(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      _setError('Por favor completa todos los campos');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('Por favor ingresa un correo válido');
      return false;
    }

    return true;
  }

  // Validación de entrada para registro
  bool _validateRegisterInput(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _setError('Por favor completa todos los campos');
      return false;
    }

    if (!_isValidEmail(email)) {
      _setError('Por favor ingresa un correo válido');
      return false;
    }

    if (password.length < 6) {
      _setError('La contraseña debe tener al menos 6 caracteres');
      return false;
    }

    if (password != confirmPassword) {
      _setError('Las contraseñas no coinciden');
      return false;
    }

    return true;
  }

  // Validación de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Gestión de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setToken(String token) {
    _userToken = token;
  }

  void _setUserData(UserModel data) {
    _userData = data;
  }

  @override
  void dispose() {
    // Limpiar controladores para prevenir memory leaks
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }
}
