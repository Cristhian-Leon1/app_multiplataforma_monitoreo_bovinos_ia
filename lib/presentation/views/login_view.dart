import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/custom_button.dart';
import '../widgets/app_logo.dart';
import '../widgets/unfocus_wrapper.dart';
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

  late AuthProvider _authProvider;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final translateText = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: UnfocusWrapper(
        child: Container(
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
                Expanded(flex: 3, child: _buildTextAndLogo()),
                Expanded(
                  flex: 10,
                  child: _buildPrincipalContent(authProvider, translateText),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextAndLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const AppLogo(size: 80),
        const SizedBox(height: 10),
        Text(
          AppConstants.appName,
          style: AppTextStyles.splashTitle.copyWith(fontSize: 24),
        ),
      ],
    );
  }

  Widget _buildPrincipalContent(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: AppTheme.blackColor.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Título del formulario (fijo en la parte superior)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                authProvider.isLoginMode
                    ? translateText.loginTitle
                    : translateText.registerTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (authProvider.errorMessage != null) ...[
                        _buildExistingErrorMessage(authProvider),
                      ],
                      _buildLoginRegisterForm(authProvider, translateText),
                      const SizedBox(height: 20),
                      _buildButtonLoginRegister(authProvider, translateText),
                      const SizedBox(height: 15),
                      _buildToggleAuthMode(authProvider, translateText),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingErrorMessage(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              authProvider.errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRegisterForm(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    return Form(
      key: authProvider.isLoginMode ? _loginFormKey : _registerFormKey,
      child: authProvider.isLoginMode
          ? _buildLoginForm(authProvider, translateText)
          : _buildRegisterForm(authProvider, translateText),
    );
  }

  Widget _buildButtonLoginRegister(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    if (authProvider.isLoading) {
      return Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          const SizedBox(height: 15),
          Text(
            translateText.processing,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      );
    } else {
      return CustomButton(
        text: authProvider.isLoginMode
            ? translateText.login
            : translateText.register,
        onPressed: () => _handleAuth(authProvider),
        backgroundColor: AppTheme.primaryColor,
      );
    }
  }

  Widget _buildToggleAuthMode(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    return TextButton(
      onPressed: () {
        authProvider.toggleAuthMode();
      },
      child: RichText(
        text: TextSpan(
          text: authProvider.isLoginMode
              ? translateText.dontHaveAccount
              : translateText.alreadyHaveAccount,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          children: [
            TextSpan(
              text: authProvider.isLoginMode
                  ? translateText.createOne
                  : translateText.signIn,
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    return Column(
      children: [
        AuthTextField(
          controller: authProvider.loginEmailController,
          hintText: translateText.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.loginPasswordController,
          hintText: translateText.password,
          prefixIcon: Icons.lock_outlined,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showResetPasswordDialog(translateText),
            child: Text(
              translateText.forgotPassword,
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

  Widget _buildRegisterForm(
    AuthProvider authProvider,
    AppLocalizations translateText,
  ) {
    return Column(
      children: [
        AuthTextField(
          controller: authProvider.registerNameController,
          hintText: translateText.fullName,
          prefixIcon: Icons.person_outlined,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerEmailController,
          hintText: translateText.email,
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerPasswordController,
          hintText: translateText.password,
          prefixIcon: Icons.lock_outlined,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
        const SizedBox(height: 15),
        AuthTextField(
          controller: authProvider.registerConfirmPasswordController,
          hintText: translateText.confirmPassword,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.emailAddress,
          isPassword: true,
        ),
      ],
    );
  }

  Future<void> _handleAuth(AuthProvider authProvider) async {
    FocusScope.of(context).unfocus();
    if (authProvider.isLoginMode) {
      final success = await authProvider.login();
      if (success) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        }
      }
    } else {
      final success = await authProvider.register();
      if (success) {
        _showRegistrationSuccessDialog(authProvider);
      }
    }
  }

  void _showResetPasswordDialog(AppLocalizations translateText) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translateText.resetPassword),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(translateText.resetPasswordMessage),
              const SizedBox(height: 20),
              AuthTextField(
                controller: emailController,
                hintText: translateText.email,
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
                translateText.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.trim().isNotEmpty) {
                  final email = emailController.text.trim();
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  navigator.pop();
                  final success = await _authProvider.resetPassword(email);
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? translateText.recoverSend
                              : translateText.recoverError,
                        ),
                        backgroundColor: success
                            ? AppTheme.primaryColor
                            : AppTheme.errorColor,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.surfaceColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(translateText.send),
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationSuccessDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
                authProvider.loginEmailController.text =
                    authProvider.registerEmailController.text;
                authProvider.loginPasswordController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Continuar al Login',
              ), // _localizations.continueLogin),
            ),
          ],
        );
      },
    );
  }
}
