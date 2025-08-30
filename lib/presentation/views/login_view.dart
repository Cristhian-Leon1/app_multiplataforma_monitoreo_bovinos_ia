import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_logo.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../core/app_localizations.dart';
import '../../core/app_routes.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Instancias optimizadas
  late AuthProvider _authProvider;
  late AppLocalizations _localizations;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Instanciar providers y localizations una sola vez
    _authProvider = Provider.of<AuthProvider>(context);
    _localizations = AppLocalizations.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF81C784),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo
                    const AppLogo(size: 80),
                    const SizedBox(height: 10),
                    // Nombre de la app
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.splashTitle.copyWith(fontSize: 24),
                    ),
                  ],
                ),
              ),

              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                    ),
                    child: _buildFormContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          children: [
            // Título del formulario (fijo en la parte superior)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                authProvider.isLoginMode
                    ? _localizations.loginTitle
                    : _localizations.registerTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                  fontSize: 26,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contenido centrado en el espacio restante
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Mostrar error si existe
                      if (authProvider.errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.red[200]!,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Formulario
                      _buildForm(authProvider),

                      const SizedBox(height: 20),

                      // Botón principal
                      if (authProvider.isLoading)
                        Column(
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              _localizations.processing,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        )
                      else
                        CustomButton(
                          text: authProvider.isLoginMode
                              ? _localizations.login
                              : _localizations.register,
                          onPressed: () => _handleAuth(authProvider),
                          backgroundColor: const Color(0xFF2E7D32),
                        ),

                      const SizedBox(height: 15),

                      // Toggle entre login y registro
                      TextButton(
                        onPressed: () {
                          _authProvider.toggleAuthMode();
                        },
                        child: RichText(
                          text: TextSpan(
                            text: authProvider.isLoginMode
                                ? _localizations.dontHaveAccount
                                : _localizations.alreadyHaveAccount,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey[600]),
                            children: [
                              TextSpan(
                                text: authProvider.isLoginMode
                                    ? _localizations.createOne
                                    : _localizations.signIn,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm(AuthProvider authProvider) {
    return Form(
      key: authProvider.isLoginMode ? _loginFormKey : _registerFormKey,
      child: authProvider.isLoginMode
          ? _buildLoginForm(authProvider)
          : _buildRegisterForm(authProvider),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Column(
      children: [
        AuthTextField(
          controller: authProvider.loginEmailController,
          hintText: _localizations.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.loginPasswordController,
          hintText: _localizations.password,
          prefixIcon: Icons.lock_outlined,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showResetPasswordDialog(),
            child: Text(
              _localizations.forgotPassword,
              style: TextStyle(
                color: Colors.grey[600],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Column(
      children: [
        AuthTextField(
          controller: authProvider.registerNameController,
          hintText: _localizations.fullName,
          prefixIcon: Icons.person_outlined,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerEmailController,
          hintText: _localizations.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerPasswordController,
          hintText: _localizations.password,
          prefixIcon: Icons.lock_outlined,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerConfirmPasswordController,
          hintText: _localizations.confirmPassword,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
      ],
    );
  }

  Future<void> _handleAuth(AuthProvider authProvider) async {
    // Cerrar el teclado antes de procesar
    FocusScope.of(context).unfocus();

    if (authProvider.isLoginMode) {
      final success = await authProvider.login();
      
      if (success) {
        // Si el login fue exitoso, navegar a HomeView
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      }
    } else {
      // Intentar registrar usuario
      final success = await authProvider.register();
      
      if (success) {
        // Si el registro fue exitoso, cambiar al modo login y mostrar diálogo
        _showRegistrationSuccessDialog(authProvider);
      }
    }
  }

  void _showResetPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_localizations.resetPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_localizations.resetPasswordMessage),
              const SizedBox(height: 20),
              AuthTextField(
                controller: emailController,
                hintText: _localizations.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                _localizations.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  final success = await _authProvider.resetPassword(
                    emailController.text.trim(),
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Correo de recuperación enviado'
                              : 'Error al enviar correo de recuperación',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(_localizations.send),
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationSuccessDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando fuera
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green[600],
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                'Éxito', // _localizations.success,
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Usuario creado exitosamente!', // _localizations.userCreatedSuccessfully,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Text(
                'Ahora puedes iniciar sesión con tus credenciales.', // _localizations.nowCanLogin,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Cambiar al modo login y limpiar campos
                authProvider.toggleAuthMode();
                // Limpiar el campo de email del login y poner el email registrado
                authProvider.loginEmailController.text = authProvider.registerEmailController.text;
                authProvider.loginPasswordController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Continuar al Login'), // _localizations.continueLogin),
            ),
          ],
        );
      },
    );
  }
}
