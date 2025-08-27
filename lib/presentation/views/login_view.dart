import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_textfield.dart';
import '../widgets/custom_button.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF4CAF50),
              Color(0xFF81C784),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Logo en la parte superior
            Positioned(
              top: size.height * 0.08,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Image.asset(
                          AppConstants.logoPath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.agriculture,
                              size: 40,
                              color: Color(0xFF2E7D32),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      AppConstants.appName,
                      style: AppTextStyles.splashTitle.copyWith(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),

            // Contenedor del formulario (70% desde abajo)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size.height * 0.7,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            const SizedBox(height: 40),

                            // Título del formulario
                            Text(
                              authProvider.isLoginMode
                                  ? 'Iniciar Sesión'
                                  : 'Crear Cuenta',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: const Color(0xFF2E7D32),
                                    fontSize: 28,
                                  ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              authProvider.isLoginMode
                                  ? 'Bienvenido de vuelta'
                                  : 'Únete a nuestra comunidad',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey[600]),
                            ),

                            const SizedBox(height: 30),

                            // Formulario
                            Expanded(
                              child: SingleChildScrollView(
                                child: authProvider.isLoginMode
                                    ? _buildLoginForm(authProvider)
                                    : _buildRegisterForm(authProvider),
                              ),
                            ),

                            // Botón de alternar entre login y registro
                            Padding(
                              padding: const EdgeInsets.only(bottom: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    authProvider.isLoginMode
                                        ? '¿No tienes una cuenta? '
                                        : '¿Ya tienes una cuenta? ',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      authProvider.toggleAuthMode();
                                    },
                                    child: Text(
                                      authProvider.isLoginMode
                                          ? 'Regístrate'
                                          : 'Inicia Sesión',
                                      style: AppTextStyles.linkText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(AuthProvider authProvider) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          // Email
          AuthTextField(
            controller: authProvider.loginEmailController,
            hintText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),

          // Contraseña
          AuthTextField(
            controller: authProvider.loginPasswordController,
            hintText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),

          // Link de olvidé mi contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // TODO: Implementar recuperar contraseña
              },
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: AppTextStyles.linkText.copyWith(
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Mostrar error si existe
          if (authProvider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Botón de login
          CustomButton(
            text: 'Iniciar Sesión',
            isLoading: authProvider.isLoading,
            onPressed: () async {
              if (_loginFormKey.currentState!.validate()) {
                final success = await authProvider.login();
                if (success && mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegisterForm(AuthProvider authProvider) {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          // Nombre
          AuthTextField(
            controller: authProvider.registerNameController,
            hintText: 'Nombre completo',
            prefixIcon: Icons.person_outline,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nombre';
              }
              return null;
            },
          ),

          // Email
          AuthTextField(
            controller: authProvider.registerEmailController,
            hintText: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Por favor ingresa un correo válido';
              }
              return null;
            },
          ),

          // Contraseña
          AuthTextField(
            controller: authProvider.registerPasswordController,
            hintText: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa una contraseña';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),

          // Confirmar contraseña
          AuthTextField(
            controller: authProvider.registerConfirmPasswordController,
            hintText: 'Confirmar contraseña',
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != authProvider.registerPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),

          const SizedBox(height: 10),

          // Mostrar error si existe
          if (authProvider.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authProvider.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Botón de registro
          CustomButton(
            text: 'Crear Cuenta',
            isLoading: authProvider.isLoading,
            onPressed: () async {
              if (_registerFormKey.currentState!.validate()) {
                final success = await authProvider.register();
                if (success && mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/home', (route) => false);
                }
              }
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
