import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cattle_identification_provider.dart';
import '../widgets/image_capture_container.dart';
import '../widgets/custom_textfield.dart';
import '../../core/app_localizations.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  // Método para obtener el nombre completo del usuario
  String _getUserDisplayName(AuthProvider authProvider) {
    final userData = authProvider.userData;
    if (userData?.perfil?.nombreCompleto != null &&
        userData!.perfil!.nombreCompleto!.isNotEmpty) {
      return userData.perfil!.nombreCompleto!;
    }
    return userData?.email ?? 'Usuario';
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
                  color: Colors.white.withOpacity(0.8),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
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
        return _buildIdentifyPage(context, localizations);
      case 1:
        return _buildStatisticsPage(context, localizations);
      case 2:
        return _buildProfilePage(context, authProvider, localizations);
      default:
        return _buildIdentifyPage(context, localizations);
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
            color: Colors.black.withOpacity(0.1),
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
        unselectedItemColor: Colors.white.withOpacity(0.6),
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.camera_alt, size: 24),
            ),
            label: localizations.identifyCattle,
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 1
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.analytics, size: 24),
            ),
            label: localizations.statistics,
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: _currentIndex == 2
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Icon(Icons.person, size: 24),
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // Página 1: Identificar Bovino
  Widget _buildIdentifyPage(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Consumer<CattleIdentificationProvider>(
      builder: (context, cattleProvider, child) {
        return GestureDetector(
          onTap: () {
            // Remover el foco del TextField cuando se toca en cualquier parte de la pantalla
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frase descriptiva
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Text(
                    'Utiliza la visión artificial para obtener medidas y características de los bovinos.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Mensajes de error
                if (cattleProvider.errorMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cattleProvider.errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          onPressed: cattleProvider.clearError,
                          icon: Icon(Icons.close, color: Colors.red[600]),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),

                // Campo de texto para Bovino ID
                BovinoIdTextField(
                  controller: cattleProvider.bovinoIdController,
                  validator: cattleProvider.validateBovinoId,
                  onChanged: cattleProvider.onBovinoIdChanged,
                  onUnfocus: cattleProvider.onBovinoIdUnfocus,
                  enabled: !cattleProvider.isLoading,
                ),

                const SizedBox(height: 30),

                // Contenedores de imágenes
                Column(
                  children: [
                    // Fila de contenedores de imágenes
                    Row(
                      children: [
                        // Imagen lateral
                        Expanded(
                          child: Column(
                            children: [
                              ImageCaptureContainer(
                                title: 'Vista Lateral',
                                image: cattleProvider.lateralImage,
                                isLoading: cattleProvider.isLoadingLateral,
                              ),
                              const SizedBox(height: 8),
                              // Botones para imagen lateral
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildCameraButton(
                                    onPressed: cattleProvider
                                        .captureLateralImageFromCamera,
                                    isLoading: cattleProvider.isLoadingLateral,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildGalleryButton(
                                    onPressed: cattleProvider
                                        .captureLateralImageFromGallery,
                                    isLoading: cattleProvider.isLoadingLateral,
                                  ),
                                  if (cattleProvider.hasLateralImage) ...[
                                    const SizedBox(width: 8),
                                    _buildDeleteButton(
                                      onPressed:
                                          cattleProvider.removeLateralImage,
                                      isLoading:
                                          cattleProvider.isLoadingLateral,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Imagen trasera
                        Expanded(
                          child: Column(
                            children: [
                              ImageCaptureContainer(
                                title: 'Vista Trasera',
                                image: cattleProvider.rearImage,
                                isLoading: cattleProvider.isLoadingRear,
                              ),
                              const SizedBox(height: 8),
                              // Botones para imagen trasera
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _buildCameraButton(
                                    onPressed: cattleProvider
                                        .captureRearImageFromCamera,
                                    isLoading: cattleProvider.isLoadingRear,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildGalleryButton(
                                    onPressed: cattleProvider
                                        .captureRearImageFromGallery,
                                    isLoading: cattleProvider.isLoadingRear,
                                  ),
                                  if (cattleProvider.hasRearImage) ...[
                                    const SizedBox(width: 8),
                                    _buildDeleteButton(
                                      onPressed: cattleProvider.removeRearImage,
                                      isLoading: cattleProvider.isLoadingRear,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Botón de analizar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        cattleProvider.canAnalyze && !cattleProvider.isAnalyzing
                        ? cattleProvider.analyzeCattle
                        : null,
                    icon: cattleProvider.isAnalyzing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.analytics),
                    label: Text(
                      cattleProvider.isAnalyzing
                          ? 'Analizando...'
                          : 'Analizar Bovino',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cattleProvider.canAnalyze
                          ? const Color(0xFF4CAF50)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: cattleProvider.canAnalyze ? 3 : 0,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón de limpiar formulario
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: !cattleProvider.isLoading
                        ? cattleProvider.clearForm
                        : null,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Limpiar Todo'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // Página 2: Estadísticas
  Widget _buildStatisticsPage(
    BuildContext context,
    AppLocalizations localizations,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frase descriptiva
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            'Visualiza reportes y estadísticas detalladas de tu ganado para tomar mejores decisiones.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Contenido principal - Cards de estadísticas
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            children: [
              _buildStatsCard(
                icon: Icons.pets,
                title: 'Total Bovinos',
                value: '0',
                color: const Color(0xFF4CAF50),
              ),
              _buildStatsCard(
                icon: Icons.health_and_safety,
                title: 'Sanos',
                value: '0',
                color: const Color(0xFF2E7D32),
              ),
              _buildStatsCard(
                icon: Icons.warning,
                title: 'En Alerta',
                value: '0',
                color: const Color(0xFF81C784),
              ),
              _buildStatsCard(
                icon: Icons.trending_up,
                title: 'Análisis IA',
                value: '0',
                color: const Color(0xFF1B5E20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Página 3: Perfil
  Widget _buildProfilePage(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    final userData = authProvider.userData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Frase descriptiva
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Text(
            'Gestiona tu información personal y configuraciones de la aplicación.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Información del usuario
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF4CAF50).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              // Avatar del usuario - imagen o inicial
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF4CAF50),
                backgroundImage:
                    userData?.perfil?.imagenPerfil != null &&
                        userData!.perfil!.imagenPerfil!.isNotEmpty
                    ? NetworkImage(userData.perfil!.imagenPerfil!)
                    : null,
                child:
                    (userData?.perfil?.imagenPerfil == null ||
                        userData!.perfil!.imagenPerfil!.isEmpty)
                    ? Text(
                        (userData?.perfil?.nombreCompleto?.isNotEmpty ?? false)
                            ? userData!.perfil!.nombreCompleto![0].toUpperCase()
                            : userData?.email[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 15),
              Text(
                _getUserDisplayName(authProvider),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                userData?.email ?? '',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Opciones del perfil
        _buildProfileOption(
          icon: Icons.edit,
          title: 'Editar Perfil',
          subtitle: 'Actualizar información personal',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.comingSoon),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          },
        ),

        const SizedBox(height: 15),

        _buildProfileOption(
          icon: Icons.settings,
          title: 'Configuración',
          subtitle: 'Preferencias de la aplicación',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.comingSoon),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          },
        ),

        const SizedBox(height: 15),

        _buildProfileOption(
          icon: Icons.help_outline,
          title: 'Ayuda',
          subtitle: 'Soporte y documentación',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localizations.comingSoon),
                backgroundColor: const Color(0xFF4CAF50),
              ),
            );
          },
        ),

        const Spacer(),

        // Botón de logout
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton.icon(
            onPressed: () {
              _showLogoutDialog(context, authProvider, localizations);
            },
            icon: const Icon(Icons.logout),
            label: Text(localizations.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.logout),
          content: Text(localizations.logoutConfirm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.logout),
            ),
          ],
        );
      },
    );
  }

  // Métodos auxiliares para construcción de botones

  Widget _buildCameraButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      icon: Icons.camera_alt,
      backgroundColor: const Color(0xFF4CAF50),
      onPressed: onPressed,
      tooltip: 'Capturar desde cámara',
      isEnabled: !isLoading,
    );
  }

  Widget _buildGalleryButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      icon: Icons.photo_library,
      backgroundColor: const Color(0xFF2E7D32),
      onPressed: onPressed,
      tooltip: 'Seleccionar desde galería',
      isEnabled: !isLoading,
    );
  }

  Widget _buildDeleteButton({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ActionButton(
      icon: Icons.delete,
      backgroundColor: Colors.red,
      onPressed: onPressed,
      tooltip: 'Eliminar imagen',
      isEnabled: !isLoading,
    );
  }
}
