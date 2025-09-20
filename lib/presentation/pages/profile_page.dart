import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cattle_identification_provider.dart';
import '../widgets/unfocus_wrapper.dart';
import '../../core/app_localizations.dart';
import '../../core/image_utils.dart';

class ProfilePage extends StatelessWidget {
  final AuthProvider authProvider;
  final BuildContext homeContext;

  const ProfilePage({
    super.key,
    required this.authProvider,
    required this.homeContext,
  });

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
    final localizations = AppLocalizations.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userData = authProvider.userData;

        return UnfocusWrapper(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
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
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // Avatar del usuario - imagen o inicial
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: const Color(0xFF4CAF50),
                                backgroundImage:
                                    userData?.perfil?.imagenPerfil != null &&
                                        userData!
                                            .perfil!
                                            .imagenPerfil!
                                            .isNotEmpty
                                    ? NetworkImage(
                                        userData.perfil!.imagenPerfil!,
                                      )
                                    : null,
                                child:
                                    (userData?.perfil?.imagenPerfil == null ||
                                        userData!.perfil!.imagenPerfil!.isEmpty)
                                    ? Text(
                                        (userData
                                                    ?.perfil
                                                    ?.nombreCompleto
                                                    ?.isNotEmpty ??
                                                false)
                                            ? userData!
                                                  .perfil!
                                                  .nombreCompleto![0]
                                                  .toUpperCase()
                                            : userData?.email[0]
                                                      .toUpperCase() ??
                                                  'U',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            // Icono de edición para indicar que es clickeable
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => _showImageUploadDialog(
                                  context,
                                  authProvider,
                                ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            // Overlay de carga si se está subiendo imagen
                            if (authProvider.isLoading)
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          _getUserDisplayName(authProvider),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2E7D32),
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          userData?.email ?? '',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Mostrar errores si los hay
                if (authProvider.errorMessage != null) ...[
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
                            authProvider.errorMessage!,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                        IconButton(
                          onPressed: () => authProvider.clearError(),
                          icon: Icon(Icons.close, color: Colors.red[600]),
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),
                ],

                // Opciones del perfil
                _buildProfileOption(
                  context,
                  localizations,
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
                  context,
                  localizations,
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

                const SizedBox(height: 40),

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
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Mostrar diálogo para seleccionar y subir imagen de perfil
  void _showImageUploadDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    try {
      final String? base64Image = await ImageUtils.showImageSourceDialog(
        context,
      );

      if (base64Image != null) {
        final success = await authProvider.uploadProfileImage(base64Image);

        if (success && context.mounted) {
          // Verificar si hay algún mensaje de advertencia
          String message = 'Imagen de perfil actualizada exitosamente';
          Color backgroundColor = const Color(0xFF4CAF50);

          if (authProvider.errorMessage?.isNotEmpty == true) {
            message =
                'Imagen subida correctamente. ${authProvider.errorMessage}';
            backgroundColor = const Color(
              0xFFFF9800,
            ); // Naranja para advertencia
            authProvider
                .clearError(); // Limpiar el mensaje después de mostrarlo
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(
                seconds: 4,
              ), // Más tiempo para leer advertencias
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildProfileOption(
    BuildContext context,
    AppLocalizations localizations, {
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
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
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
              onPressed: () async {
                Navigator.of(context).pop();

                // Obtener referencia al CattleIdentificationProvider
                final cattleProvider =
                    Provider.of<CattleIdentificationProvider>(
                      homeContext,
                      listen: false,
                    );

                // Hacer logout y limpiar todos los providers
                await authProvider.logout(
                  onClearProviders: () {
                    // Limpiar datos del CattleIdentificationProvider
                    cattleProvider.clearAllData();
                    // Aquí se pueden agregar otros providers cuando sean necesarios
                  },
                );

                // Usar el contexto del HomeView para navegar
                if (homeContext.mounted) {
                  Navigator.of(
                    homeContext,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                }
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
}
