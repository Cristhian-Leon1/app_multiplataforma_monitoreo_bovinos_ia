import 'dart:io';
import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar contenedores de imágenes con indicador de carga
class ImageCaptureContainer extends StatelessWidget {
  final String title;
  final File? image;
  final bool isLoading;

  const ImageCaptureContainer({
    super.key,
    required this.title,
    required this.image,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: image == null
            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Contenido principal
          if (image == null)
            _buildEmptyState(context)
          else
            _buildImageState(context),

          // Indicador de carga
          if (isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt_outlined,
            size: 50,
            color: const Color(0xFF2E7D32).withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E7D32),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            'Toca los botones para capturar',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageState(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        image: DecorationImage(image: FileImage(image!), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.3)],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }
}

/// Widget reutilizable para botones de acción (cámara, galería, eliminar)
class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isEnabled;

  const ActionButton({
    super.key,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    required this.tooltip,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled
              ? backgroundColor.withValues(alpha: 0.9)
              : Colors.grey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: isEnabled ? onPressed : null,
          icon: Icon(icon, color: Colors.white, size: 20),
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }
}
