import 'package:app_multiplataforma_monitoreo_bovinos_ia/presentation/pages/cattle_pens_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/auth_provider.dart';
import '../providers/statistics_provider.dart';
import '../../core/app_localizations.dart';
import '../pages/cattle_identification_page.dart';
import '../pages/statistics_page.dart';
import '../pages/profile_page.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 1;
  bool _hasInitializedStatistics = false;

  @override
  void initState() {
    super.initState();
    // Inicializar datos después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeStatisticsData();
    });
  }

  void _initializeStatisticsData() {
    if (!_hasInitializedStatistics) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final statisticsProvider = Provider.of<StatisticsProvider>(
        context,
        listen: false,
      );

      if (authProvider.isLoggedIn && authProvider.userToken != null) {
        statisticsProvider.initializeData(authProvider.userToken!);
        _hasInitializedStatistics = true;
      }
    }
  }

  // Método público para cambiar de tab desde widgets hijos
  void changeTab(int index) {
    if (mounted) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Método para obtener el nombre completo del usuario
  String _getUserDisplayName(AuthProvider authProvider) {
    final userData = authProvider.userData;
    if (userData?.perfil?.nombreCompleto != null &&
        userData!.perfil!.nombreCompleto!.isNotEmpty) {
      return userData.perfil!.nombreCompleto!;
    }
    return userData?.email ?? 'Usuario';
  }

  // Método para crear el avatar del usuario (imagen de perfil o icono por defecto)
  Widget _buildUserAvatar(AuthProvider authProvider) {
    final userData = authProvider.userData;
    final imagenPerfil = userData?.perfil?.imagenPerfil;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: imagenPerfil != null && imagenPerfil.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Image.network(
                imagenPerfil,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 28,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            )
          : const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  // Método para crear el avatar pequeño del bottom navigation
  Widget _buildBottomNavAvatar(AuthProvider authProvider) {
    final userData = authProvider.userData;
    final imagenPerfil = userData?.perfil?.imagenPerfil;

    return imagenPerfil != null && imagenPerfil.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imagenPerfil,
              width: 28,
              height: 28,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.person, size: 24);
              },
            ),
          )
        : const Icon(Icons.person, size: 24);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
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
              // Barra superior fija con información del usuario
              _buildUserHeader(context, authProvider),

              // Contenido principal que cambia según la navegación
              Expanded(
                child: _buildCurrentPageContent(
                  context,
                  authProvider,
                  localizations,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(localizations),
    );
  }

  // Barra superior fija con información del usuario
  Widget _buildUserHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bienvenido',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                _getUserDisplayName(authProvider),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _buildUserAvatar(authProvider),
        ],
      ),
    );
  }

  Widget _buildCurrentPageContent(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildCurrentPage(context, authProvider, localizations),
      ),
    );
  }

  Widget _buildCurrentPage(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    switch (_currentIndex) {
      case 0:
        return const CattleIdentificationPage();
      case 1:
        return const StatisticsPage();
      case 2:
        return const CattlePensPage();
      case 3:
        return ProfilePage(authProvider: authProvider, homeContext: context);
      default:
        return const CattleIdentificationPage();
    }
  }

  Widget _buildBottomNavigationBar(AppLocalizations localizations) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withValues(alpha: 0.6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 0
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.camera_alt, size: 24),
            ),
            label: 'Caracterización',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.analytics, size: 24),
            ),
            label: 'Mi Finca',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: SvgPicture.asset(
                'assets/icons/icono_cerca.svg',
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  _currentIndex == 2
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  BlendMode.srcIn,
                ),
              ),
            ),
            label: 'Corrales',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 3
                  ? BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return _buildBottomNavAvatar(authProvider);
                },
              ),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
