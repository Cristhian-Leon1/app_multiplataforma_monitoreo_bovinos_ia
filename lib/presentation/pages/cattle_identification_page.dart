import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cattle_identification_provider.dart';
import '../providers/statistics_provider.dart';
import '../widgets/image_capture_container.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/pose_results_widget.dart';
import '../widgets/unfocus_wrapper.dart';
import '../views/home_view.dart';

class CattleIdentificationPage extends StatelessWidget {
  const CattleIdentificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CattleIdentificationProvider, StatisticsProvider>(
      builder: (context, cattleProvider, statisticsProvider, child) {
        return Column(
          children: [
            // Texto descriptivo fijo (siempre visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
              child: Text(
                'Caracteriza los bovinos de tu finca registrando sus características con el apoyo de visión artificial.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Contenido variable según el estado
            Expanded(
              child: _buildVariableContent(
                context,
                cattleProvider,
                statisticsProvider,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVariableContent(
    BuildContext context,
    CattleIdentificationProvider cattleProvider,
    StatisticsProvider statisticsProvider,
  ) {
    // Si está cargando, mostrar loading centrado
    if (statisticsProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            SizedBox(height: 16),
            Text('Verificando fincas...'),
          ],
        ),
      );
    }

    // Si no hay fincas registradas, mostrar mensaje centrado
    if (!statisticsProvider.hasFincas) {
      return _buildNoFincaMessage(context);
    }

    // Si hay fincas, mostrar la interfaz normal con scroll
    return _buildCattleIdentificationContent(context, cattleProvider);
  }

  Widget _buildCattleIdentificationContent(
    BuildContext context,
    CattleIdentificationProvider cattleProvider,
  ) {
    return UnfocusWrapper(
      child: SingleChildScrollView(
        // Agregar scroll para evitar overflow
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const SizedBox(height: 20),

            CustomDropdown(
              value: cattleProvider.selectedSex,
              items: cattleProvider.sexOptions,
              hint: 'Sexo',
              onChanged: cattleProvider.setSex,
              enabled: !cattleProvider.isLoading,
              prefixIcon: const Icon(Icons.pets, color: Color(0xFF4CAF50)),
            ),

            const SizedBox(height: 20),

            // Dropdown de raza
            CustomDropdown(
              value: cattleProvider.selectedBreed,
              items: cattleProvider.breedOptions,
              hint: 'Raza',
              onChanged: cattleProvider.setBreed,
              enabled: !cattleProvider.isLoading,
              prefixIcon: const Icon(Icons.category, color: Color(0xFF4CAF50)),
            ),

            const SizedBox(height: 20),

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
                                  onPressed: cattleProvider.removeLateralImage,
                                  isLoading: cattleProvider.isLoadingLateral,
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
                                onPressed:
                                    cattleProvider.captureRearImageFromCamera,
                                isLoading: cattleProvider.isLoadingRear,
                              ),
                              const SizedBox(width: 8),
                              _buildGalleryButton(
                                onPressed:
                                    cattleProvider.captureRearImageFromGallery,
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
                    ? () => _analyzeCattle(context, cattleProvider)
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
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
  }

  /// Función para manejar el análisis de bovinos
  Future<void> _analyzeCattle(
    BuildContext context,
    CattleIdentificationProvider cattleProvider,
  ) async {
    // Ejecutar el análisis
    await cattleProvider.analyzeCattle();

    // Si hay errores, no mostrar el dialog
    if (cattleProvider.errorMessage != null) {
      return;
    }

    // Si hay resultados, mostrar el dialog
    if (cattleProvider.analysisResults != null &&
        cattleProvider.analysisResults!.isNotEmpty) {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              PoseResultsDialog(results: cattleProvider.analysisResults!),
        );
      }
    }
  }
}

// Métodos auxiliares para construir botones
Widget _buildCameraButton({
  required VoidCallback onPressed,
  required bool isLoading,
}) {
  return ActionButton(
    icon: Icons.camera_alt,
    backgroundColor: const Color(0xFF2E7D32),
    onPressed: isLoading ? () {} : onPressed,
    tooltip: 'Tomar foto',
    isEnabled: !isLoading,
  );
}

Widget _buildGalleryButton({
  required VoidCallback onPressed,
  required bool isLoading,
}) {
  return ActionButton(
    icon: Icons.photo_library,
    backgroundColor: const Color(0xFF1976D2),
    onPressed: isLoading ? () {} : onPressed,
    tooltip: 'Seleccionar de galería',
    isEnabled: !isLoading,
  );
}

Widget _buildDeleteButton({
  required VoidCallback onPressed,
  required bool isLoading,
}) {
  return ActionButton(
    icon: Icons.delete,
    backgroundColor: const Color(0xFFD32F2F),
    onPressed: isLoading ? () {} : onPressed,
    tooltip: 'Eliminar imagen',
    isEnabled: !isLoading,
  );
}

Widget _buildNoFincaMessage(BuildContext context) {
  return Center(
    child: Container(
      margin: const EdgeInsets.all(7),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.agriculture,
              size: 48,
              color: Color(0xFF4CAF50),
            ),
          ),

          const SizedBox(height: 20),

          // Título
          Text(
            'Finca requerida',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Mensaje
          Text(
            'Para caracterizar bovinos, primero debes registrar tu finca.\n\nVe al apartado "Mi Finca" para crear tu finca.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Botón para ir a Mi Finca
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Buscar el widget padre que contiene el BottomNavigationBar
                try {
                  final homeViewState = context
                      .findAncestorStateOfType<State<HomeView>>();
                  if (homeViewState != null) {
                    // Cambiar al índice 1 (Mi Finca) usando reflexión
                    (homeViewState as dynamic).changeTab(1);
                  } else {
                    // Fallback: mostrar SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ve a la pestaña "Mi Finca" para registrar tu finca',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Color(0xFF4CAF50),
                      ),
                    );
                  }
                } catch (e) {
                  // Si hay error, mostrar SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ve a la pestaña "Mi Finca" para registrar tu finca',
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Ir a Mi Finca'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
