import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cattle_identification_provider.dart';
import '../widgets/image_capture_container.dart';
import '../widgets/custom_textfield.dart';

class CattleIdentificationPage extends StatelessWidget {
  const CattleIdentificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CattleIdentificationProvider>(
      builder: (context, cattleProvider, child) {
        return GestureDetector(
          onTap: () {
            // Remover el foco del TextField cuando se toca en cualquier parte de la pantalla
            FocusScope.of(context).unfocus();
          },
          child: SingleChildScrollView(
            // Agregar scroll para evitar overflow
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                  prefixIcon: const Icon(
                    Icons.category,
                    color: Color(0xFF4CAF50),
                  ),
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
}
