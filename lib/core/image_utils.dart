import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Utilidades para manejar imágenes
class ImageUtils {
  static final ImagePicker _picker = ImagePicker();

  /// Seleccionar imagen desde galería o cámara y convertir a base64
  static Future<String?> pickImageAsBase64({
    ImageSource source = ImageSource.gallery,
    int? imageQuality = 80,
    double? maxWidth = 300,
    double? maxHeight = 300,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;

      // ✅ Leer bytes directamente desde XFile (funciona en Web y Móvil)
      final List<int> imageBytes = await image.readAsBytes();

      // Determinar el tipo MIME basado en la extensión o nombre
      String mimeType = 'image/jpeg';
      final String fileName = image.name.toLowerCase();

      if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (image.mimeType != null) {
        // Usar el mimeType del archivo si está disponible
        mimeType = image.mimeType!;
      }

      // Convertir a base64 CON el data URL (formato requerido por el backend)
      final String base64String = base64Encode(imageBytes);
      final String result = 'data:$mimeType;base64,$base64String';

      return result;
    } catch (e) {
      throw Exception('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  /// Seleccionar imagen y retornar con data URL prefix (para mostrar en UI)
  static Future<String?> pickImageAsBase64WithDataUrl({
    ImageSource source = ImageSource.gallery,
    int? imageQuality = 80,
    double? maxWidth = 300,
    double? maxHeight = 300,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (image == null) return null;

      // ✅ Leer bytes directamente desde XFile (funciona en Web y Móvil)
      final List<int> imageBytes = await image.readAsBytes();

      // Determinar el tipo MIME basado en la extensión o nombre
      String mimeType = 'image/jpeg';
      final String fileName = image.name.toLowerCase();

      if (fileName.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      } else if (image.mimeType != null) {
        // Usar el mimeType del archivo si está disponible
        mimeType = image.mimeType!;
      }

      // Convertir a base64 con el data URL (para mostrar en UI)
      final String base64String = base64Encode(imageBytes);
      final String result = 'data:$mimeType;base64,$base64String';

      return result;
    } catch (e) {
      throw Exception('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  /// Mostrar opciones para seleccionar imagen (galería o cámara)
  static Future<String?> showImageSourceDialog(
    BuildContext context, {
    int? imageQuality = 80,
    double? maxWidth = 300,
    double? maxHeight = 300,
  }) async {
    // ✅ En Web, ir directo a la galería (no hay cámara en web)
    if (kIsWeb) {
      return await pickImageAsBase64(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
    }

    // En móvil, mostrar opciones de galería o cámara
    final String? result = await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Seleccionar imagen',
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Elige de dónde quieres obtener la imagen',
            style: TextStyle(color: Color(0xFF424242)),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          actions: [
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pop('camera');
              },
              icon: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              label: const Text(
                'Cámara',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.of(context).pop('gallery');
              },
              icon: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              label: const Text(
                'Galería',
                style: TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result == null) return null;

    final ImageSource source = result == 'camera'
        ? ImageSource.camera
        : ImageSource.gallery;

    return await pickImageAsBase64(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }
}
