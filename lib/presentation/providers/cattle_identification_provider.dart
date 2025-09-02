import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Provider para manejar la identificación de bovinos
/// Gestiona la captura de imágenes, permisos y datos del formulario
class CattleIdentificationProvider extends ChangeNotifier {
  // Estado de la aplicación
  bool _isLoadingLateral = false;
  bool _isLoadingRear = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  // Imágenes capturadas
  File? _lateralImage;
  File? _rearImage;

  // Controller para el ID del bovino
  final TextEditingController _bovinoIdController = TextEditingController();

  // Instancia del ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Getters
  bool get isLoadingLateral => _isLoadingLateral;
  bool get isLoadingRear => _isLoadingRear;
  bool get isAnalyzing => _isAnalyzing;
  bool get isLoading => _isLoadingLateral || _isLoadingRear || _isAnalyzing;
  String? get errorMessage => _errorMessage;
  File? get lateralImage => _lateralImage;
  File? get rearImage => _rearImage;
  TextEditingController get bovinoIdController => _bovinoIdController;

  // Estado de las imágenes
  bool get hasLateralImage => _lateralImage != null;
  bool get hasRearImage => _rearImage != null;
  bool get hasAllImages => hasLateralImage && hasRearImage;
  bool get canAnalyze =>
      hasAllImages && _bovinoIdController.text.trim().isNotEmpty;

  /// Limpiar errores
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Establecer estado de carga lateral
  void _setLoadingLateral(bool loading) {
    _isLoadingLateral = loading;
    notifyListeners();
  }

  /// Establecer estado de carga trasera
  void _setLoadingRear(bool loading) {
    _isLoadingRear = loading;
    notifyListeners();
  }

  /// Establecer estado de análisis
  void _setAnalyzing(bool analyzing) {
    _isAnalyzing = analyzing;
    notifyListeners();
  }

  /// Establecer error
  void _setError(String error) {
    _errorMessage = error;
    _isLoadingLateral = false;
    _isLoadingRear = false;
    _isAnalyzing = false;
    notifyListeners();
  }

  /// Verificar y solicitar permisos de cámara
  Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _setError(
        'Los permisos de cámara están permanentemente denegados. Por favor, habilítalos en configuración.',
      );
      return false;
    }

    return false;
  }

  /// Verificar y solicitar permisos de galería
  Future<bool> _checkGalleryPermission() async {
    try {
      // En Android moderno, image_picker puede manejar los permisos automáticamente
      // Solo verificamos si podemos acceder, pero no bloqueamos si los permisos fallan
      if (Platform.isAndroid) {
        // DEBUG: Verificando permisos en Android

        // Intentamos primero con photos (Android 13+)
        var photosStatus = await Permission.photos.status;
        // DEBUG: Estado Permission.photos: $photosStatus

        if (photosStatus.isGranted) {
          // DEBUG: Permission.photos concedido
          return true;
        }

        // Intentamos con storage (Android 12 y anteriores)
        var storageStatus = await Permission.storage.status;
        // DEBUG: Estado Permission.storage: $storageStatus

        if (storageStatus.isGranted) {
          // DEBUG: Permission.storage concedido
          return true;
        }

        // Si ninguno está concedido, intentamos solicitar photos primero
        if (photosStatus.isDenied) {
          final photosResult = await Permission.photos.request();
          // DEBUG: Resultado solicitud Permission.photos: $photosResult
          if (photosResult.isGranted) {
            return true;
          }
        }

        // Si photos falla, intentamos storage
        if (storageStatus.isDenied) {
          final storageResult = await Permission.storage.request();
          // DEBUG: Resultado solicitud Permission.storage: $storageResult
          if (storageResult.isGranted) {
            return true;
          }
        }

        // IMPORTANTE: Incluso si los permisos son denegados, permitimos continuar
        // porque image_picker puede tener acceso a través del selector de archivos del sistema
        // DEBUG: Permisos denegados, pero continuando con image_picker
        return true; // Cambiado de false a true
      } else {
        // Para iOS
        final status = await Permission.photos.status;
        if (status.isGranted) {
          return true;
        }

        if (status.isDenied) {
          final result = await Permission.photos.request();
          if (result.isGranted) {
            return true;
          }
        }

        // En iOS también permitimos continuar
        // DEBUG: Permisos iOS denegados, pero continuando con image_picker
        return true;
      }
    } catch (e) {
      // DEBUG: Error en _checkGalleryPermission: $e
      // Si hay algún error, permitimos continuar
      return true;
    }
  }

  /// Capturar imagen lateral desde cámara
  Future<void> captureLateralImageFromCamera() async {
    clearError();

    if (!await _checkCameraPermission()) {
      return;
    }

    _setLoadingLateral(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        _lateralImage = File(image.path);
        _setLoadingLateral(false);
        notifyListeners();
      } else {
        _setLoadingLateral(false);
      }
    } catch (e) {
      _setError('Error al capturar imagen lateral: ${e.toString()}');
    }
  }

  /// Capturar imagen lateral desde galería
  Future<void> captureLateralImageFromGallery() async {
    // DEBUG: Iniciando captura lateral desde galería
    clearError();

    // Verificamos permisos pero continuamos incluso si no se conceden
    await _checkGalleryPermission();
    // DEBUG: Verificación de permisos completada, continuando con picker

    _setLoadingLateral(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      // DEBUG: Resultado del picker: ${image?.path}

      if (image != null) {
        _lateralImage = File(image.path);
        // DEBUG: Imagen lateral guardada: ${_lateralImage?.path}
        _setLoadingLateral(false);
        notifyListeners();
      } else {
        // DEBUG: Usuario canceló la selección
        _setLoadingLateral(false);
      }
    } catch (e) {
      // DEBUG: Error en galería lateral: $e
      _setError('Error al seleccionar imagen lateral: ${e.toString()}');
    }
  }

  /// Capturar imagen trasera desde cámara
  Future<void> captureRearImageFromCamera() async {
    clearError();

    if (!await _checkCameraPermission()) {
      return;
    }

    _setLoadingRear(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        _rearImage = File(image.path);
        _setLoadingRear(false);
        notifyListeners();
      } else {
        _setLoadingRear(false);
      }
    } catch (e) {
      _setError('Error al capturar imagen trasera: ${e.toString()}');
    }
  }

  /// Capturar imagen trasera desde galería
  Future<void> captureRearImageFromGallery() async {
    // DEBUG: Iniciando captura trasera desde galería
    clearError();

    // Verificamos permisos pero continuamos incluso si no se conceden
    await _checkGalleryPermission();
    // DEBUG: Verificación de permisos completada, continuando con picker

    _setLoadingRear(true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      // DEBUG: Resultado del picker: ${image?.path}

      if (image != null) {
        _rearImage = File(image.path);
        // DEBUG: Imagen trasera guardada: ${_rearImage?.path}
        _setLoadingRear(false);
        notifyListeners();
      } else {
        // DEBUG: Usuario canceló la selección
        _setLoadingRear(false);
      }
    } catch (e) {
      // DEBUG: Error en galería trasera: $e
      _setError('Error al seleccionar imagen trasera: ${e.toString()}');
    }
  }

  /// Eliminar imagen lateral
  void removeLateralImage() {
    _lateralImage = null;
    notifyListeners();
  }

  /// Eliminar imagen trasera
  void removeRearImage() {
    _rearImage = null;
    notifyListeners();
  }

  /// Limpiar todos los datos del formulario
  void clearForm() {
    _lateralImage = null;
    _rearImage = null;
    _bovinoIdController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar todos los datos del provider (para logout)
  void clearAllData() {
    _isLoadingLateral = false;
    _isLoadingRear = false;
    _isAnalyzing = false;
    _errorMessage = null;
    _lateralImage = null;
    _rearImage = null;
    _bovinoIdController.clear();
    notifyListeners();
  }

  /// Analizar bovino (lógica a implementar)
  Future<void> analyzeCattle() async {
    clearError();

    if (!canAnalyze) {
      _setError('Por favor, completa todos los campos requeridos.');
      return;
    }

    _setAnalyzing(true);

    try {
      // TODO: Implementar lógica de análisis con IA
      // Aquí irá la llamada a la API de análisis de bovinos

      await Future.delayed(const Duration(seconds: 2)); // Simular procesamiento

      _setAnalyzing(false);

      // Por ahora solo mostramos un mensaje de éxito
      // En el futuro aquí se navegará a la pantalla de resultados
    } catch (e) {
      _setError('Error al analizar bovino: ${e.toString()}');
    }
  }

  /// Validar que el ID del bovino sea válido
  String? validateBovinoId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El ID del bovino es obligatorio';
    }

    if (value.trim().length < 3) {
      return 'El ID debe tener al menos 3 caracteres';
    }

    // Validar que solo contenga caracteres alfanuméricos
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value.trim())) {
      return 'El ID solo puede contener letras y números';
    }

    return null;
  }

  /// Manejar cuando el TextField de Bovino ID pierde el foco
  void onBovinoIdUnfocus() {
    // Limpiar errores al perder el foco
    clearError();

    // Notificar cambios para actualizar el estado de canAnalyze
    notifyListeners();
  }

  /// Manejar cambios en el texto del Bovino ID
  void onBovinoIdChanged(String value) {
    // Limpiar errores al escribir
    clearError();

    // Notificar cambios para actualizar el estado de canAnalyze
    notifyListeners();
  }

  @override
  void dispose() {
    _bovinoIdController.dispose();
    super.dispose();
  }
}
