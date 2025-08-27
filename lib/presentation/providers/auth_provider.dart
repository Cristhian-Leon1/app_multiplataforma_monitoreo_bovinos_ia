import 'package:flutter/material.dart';

/// AuthProvider - Maneja todo el estado de autenticación de la aplicación
/// Siguiendo el principio de responsabilidad única (SRP)
class AuthProvider extends ChangeNotifier {
  // Estado de la aplicación
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  bool _isLoginMode = true; // true para login, false para registro
  String? _userToken;
  Map<String, dynamic>? _userData;

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

  // Getters para el estado
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoginMode => _isLoginMode;
  String? get userToken => _userToken;
  Map<String, dynamic>? get userData => _userData;

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

      // Simular llamada a API - Aquí iría la lógica real
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Reemplazar con llamada real a la API
      if (await _performLogin(email, password)) {
        _setUserData({'email': email, 'name': 'Usuario Demo', 'id': '123456'});
        _setToken('demo_token_123456');
        _isLoggedIn = true;
        return true;
      } else {
        _setError('Credenciales inválidas');
        return false;
      }
    } catch (e) {
      _setError('Error al iniciar sesión: ${e.toString()}');
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

      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Reemplazar con llamada real a la API
      if (await _performRegister(name, email, password)) {
        _setUserData({
          'email': email,
          'name': name,
          'id': 'new_user_${DateTime.now().millisecondsSinceEpoch}',
        });
        _setToken('new_token_${DateTime.now().millisecondsSinceEpoch}');
        _isLoggedIn = true;
        return true;
      } else {
        _setError('Error al crear la cuenta');
        return false;
      }
    } catch (e) {
      _setError('Error al registrarse: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cerrar sesión
  void logout() {
    _isLoggedIn = false;
    _userToken = null;
    _userData = null;
    _clearError();
    // TODO: Limpiar datos persistentes (SharedPreferences, SecureStorage)
    notifyListeners();
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
      // TODO: Verificar token almacenado en SharedPreferences/SecureStorage
      await Future.delayed(const Duration(milliseconds: 500));

      // Simular verificación de token
      if (_userToken != null && _userToken!.isNotEmpty) {
        _isLoggedIn = true;
        return true;
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

  // Actualizar datos del usuario
  void updateUserData(Map<String, dynamic> newData) {
    _userData = {...(_userData ?? {}), ...newData};
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

  // Simulación de login - Reemplazar con llamada real a API
  Future<bool> _performLogin(String email, String password) async {
    // TODO: Implementar llamada real a la API
    // Ejemplo: final response = await apiService.login(email, password);
    return email.isNotEmpty && password.isNotEmpty;
  }

  // Simulación de registro - Reemplazar con llamada real a API
  Future<bool> _performRegister(
    String name,
    String email,
    String password,
  ) async {
    // TODO: Implementar llamada real a la API
    // Ejemplo: final response = await apiService.register(name, email, password);
    return name.isNotEmpty && email.isNotEmpty && password.isNotEmpty;
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
    // TODO: Guardar token en SecureStorage
  }

  void _setUserData(Map<String, dynamic> data) {
    _userData = data;
    // TODO: Guardar datos del usuario en SharedPreferences
  }

  // Validación de email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
