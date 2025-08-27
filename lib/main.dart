import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/app_routes.dart';
import 'core/constants.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/views/splash_view.dart';
import 'presentation/views/login_view.dart';
import 'presentation/views/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar las barras de sistema como transparentes
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) =>
              const SystemBarsWrapper(child: AppWrapper()),
          AppRoutes.login: (context) =>
              const SystemBarsWrapper(child: LoginView()),
          AppRoutes.home: (context) =>
              const SystemBarsWrapper(child: HomeView()),
        },
      ),
    );
  }
}

/// Wrapper que maneja la navegación basada en el estado de autenticación
class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Si está autenticado, mostrar HomeView
        if (authProvider.isLoggedIn) {
          return const HomeView();
        }
        
        // Si no está autenticado, comenzar con SplashView
        return const SplashView();
      },
    );
  }
}

class SystemBarsWrapper extends StatelessWidget {
  final Widget child;

  const SystemBarsWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Configurar las barras de sistema según el tema actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemBarsConfig.setSystemBarsForTheme(context);
    });

    return child;
  }
}
