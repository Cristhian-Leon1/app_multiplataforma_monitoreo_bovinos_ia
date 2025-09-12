import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/services/pose_service.dart';
import '../../data/services/bovino_service.dart';
import '../../data/services/medicion_service.dart';
import '../../data/models/pose_model.dart';
import '../../data/models/bovino_model.dart';
import '../../data/models/medicion_model.dart';

/// Provider para manejar la identificación de bovinos
/// Gestiona la captura de imágenes, permisos y datos del formulario
class CattleIdentificationProvider extends ChangeNotifier {
  // Estado de la aplicación
  bool _isLoadingLateral = false;
  bool _isLoadingRear = false;
  bool _isAnalyzing = false;
  bool _isRegistering = false;
  String? _errorMessage;

  // Imágenes capturadas
  File? _lateralImage;
  File? _rearImage;

  // Resultados de análisis de pose
  List<PoseAnalysisResult>? _analysisResults;

  // Controller para el ID del bovino
  final TextEditingController _bovinoIdController = TextEditingController();

  // Datos adicionales del bovino
  String? _selectedSex;
  String? _selectedBreed;
  double? _altura;
  double? _longitudOblicua;
  double? _longitudCadera;
  double? _anchoCadera;
  double? _longitudTorso;
  int? _edadEstimada;
  double? _pesoEstimado;

  // Opciones para los dropdowns
  final List<String> _sexOptions = ['Macho', 'Hembra'];
  final List<String> _breedOptions = [
    'Cebú',
    'Pardo Suizo',
    'Brahman Blanco',
    'Girolando',
    'Gyr',
    'F-1',
    'Holstein',
  ];

  // Instancia del ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Getters
  bool get isLoadingLateral => _isLoadingLateral;
  bool get isLoadingRear => _isLoadingRear;
  bool get isAnalyzing => _isAnalyzing;
  bool get isRegistering => _isRegistering;
  bool get isLoading =>
      _isLoadingLateral || _isLoadingRear || _isAnalyzing || _isRegistering;
  String? get errorMessage => _errorMessage;
  File? get lateralImage => _lateralImage;
  File? get rearImage => _rearImage;
  TextEditingController get bovinoIdController => _bovinoIdController;

  // Getters para los dropdowns
  String? get selectedSex => _selectedSex;
  String? get selectedBreed => _selectedBreed;
  List<String> get sexOptions => _sexOptions;
  List<String> get breedOptions => _breedOptions;

  // Getters para medidas morfométricas
  double? get altura => _altura;
  double? get longitudOblicua => _longitudOblicua;
  double? get longitudCadera => _longitudCadera;
  double? get anchoCadera => _anchoCadera;
  double? get longitudTorso => _longitudTorso;
  int? get edadEstimada => _edadEstimada;
  double? get pesoEstimado => _pesoEstimado;

  // Getter para resultados de análisis
  List<PoseAnalysisResult>? get analysisResults => _analysisResults;

  // Estado de las imágenes
  bool get hasLateralImage => _lateralImage != null;
  bool get hasRearImage => _rearImage != null;
  bool get hasAllImages => hasLateralImage && hasRearImage;
  bool get canAnalyze =>
      hasAllImages &&
      _bovinoIdController.text.trim().isNotEmpty &&
      _selectedSex != null &&
      _selectedBreed != null;

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

  /// Establecer estado de registro
  void _setRegistering(bool registering) {
    _isRegistering = registering;
    notifyListeners();
  }

  /// Establecer error
  void _setError(String error) {
    _errorMessage = error;
    _isLoadingLateral = false;
    _isLoadingRear = false;
    _isAnalyzing = false;
    _isRegistering = false;
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
    _analysisResults = null;
    _bovinoIdController.clear();
    _selectedSex = null;
    _selectedBreed = null;
    _altura = null;
    _longitudOblicua = null;
    _longitudCadera = null;
    _anchoCadera = null;
    _longitudTorso = null;
    _edadEstimada = null;
    _pesoEstimado = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpiar todos los datos del provider (para logout)
  void clearAllData() {
    _isLoadingLateral = false;
    _isLoadingRear = false;
    _isAnalyzing = false;
    _isRegistering = false;
    _errorMessage = null;
    _lateralImage = null;
    _rearImage = null;
    _analysisResults = null;
    _bovinoIdController.clear();
    _selectedSex = null;
    _selectedBreed = null;
    _altura = null;
    _longitudOblicua = null;
    _longitudCadera = null;
    _anchoCadera = null;
    _longitudTorso = null;
    _edadEstimada = null;
    _pesoEstimado = null;
    notifyListeners();
  }

  /// Cambiar sexo seleccionado
  void setSex(String? sex) {
    _selectedSex = sex;
    clearError();
    notifyListeners();
  }

  /// Cambiar raza seleccionada
  void setBreed(String? breed) {
    _selectedBreed = breed;
    clearError();
    notifyListeners();
  }

  /// Actualizar medidas morfométricas
  void updateMorphometricMeasures({
    double? altura,
    double? longitudOblicua,
    double? longitudCadera,
    double? anchoCadera,
    double? longitudTorso,
    int? edadEstimada,
    double? pesoEstimado,
  }) {
    if (altura != null) _altura = altura;
    if (longitudOblicua != null) _longitudOblicua = longitudOblicua;
    if (longitudCadera != null) _longitudCadera = longitudCadera;
    if (anchoCadera != null) _anchoCadera = anchoCadera;
    if (longitudTorso != null) _longitudTorso = longitudTorso;
    if (edadEstimada != null) _edadEstimada = edadEstimada;
    if (pesoEstimado != null) _pesoEstimado = pesoEstimado;

    notifyListeners();
  }

  /// Analizar bovino con IA
  Future<void> analyzeCattle() async {
    clearError();

    if (!canAnalyze) {
      _setError('Por favor, completa todos los campos requeridos.');
      return;
    }

    _setAnalyzing(true);

    try {
      final List<PoseAnalysisResult> results = [];

      // Analizar imagen lateral
      if (_lateralImage != null) {
        final (lateralPrediction, lateralImageBytes) =
            await PoseService.analyzePose(_lateralImage!);
        results.add(
          PoseAnalysisResult(
            imagePath: _lateralImage!.path,
            prediction: lateralPrediction,
            imageType: 'lateral',
            resizedImageBytes: lateralImageBytes,
          ),
        );
      }

      // Analizar imagen posterior
      if (_rearImage != null) {
        final (rearPrediction, rearImageBytes) = await PoseService.analyzePose(
          _rearImage!,
        );
        results.add(
          PoseAnalysisResult(
            imagePath: _rearImage!.path,
            prediction: rearPrediction,
            imageType: 'posterior',
            resizedImageBytes: rearImageBytes,
          ),
        );
      }

      // Guardar resultados
      _analysisResults = results;
      _setAnalyzing(false);

      // Los resultados se mostrarán en la UI a través del getter analysisResults
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

  /// Registrar bovino y mediciones en el backend
  Future<Map<String, dynamic>?> registerBovinoWithMediciones({
    required String token,
    required String fincaId,
  }) async {
    clearError();

    // Validar que todos los datos necesarios están presentes
    if (_bovinoIdController.text.trim().isEmpty ||
        _selectedSex == null ||
        _selectedBreed == null) {
      _setError('Por favor, completa todos los campos requeridos.');
      return null;
    }

    _setRegistering(true);

    try {
      final idBovino = _bovinoIdController.text.trim();
      BovinoModel? bovino;
      bool bovinoCreated = false;

      // 1. Verificar si el bovino ya existe
      bovino = await BovinoService.findBovinoByIdBovino(
        token: token,
        idBovino: idBovino,
      );

      if (bovino == null) {
        // 2. El bovino no existe, crear uno nuevo
        final bovinoDto = BovinoCreateDto(
          idBovino: idBovino,
          fincaId: fincaId,
          sexo: _selectedSex,
          raza: _selectedBreed,
        );

        bovino = await BovinoService.createBovino(
          token: token,
          bovinoData: bovinoDto,
        );
        bovinoCreated = true;
      } else {
        // Bovino existente encontrado
      }

      // 3. Crear mediciones si hay datos morfométricos disponibles
      final medicionesCreadas = await _createMediciones(token, bovino.id);

      _setRegistering(false);

      return {
        'bovino': bovino,
        'bovinoCreated': bovinoCreated,
        'medicionesCount': medicionesCreadas,
      };
    } catch (e) {
      _setError('Error al registrar bovino: ${e.toString()}');
      return null;
    }
  }

  /// Crear mediciones con los datos morfométricos calculados
  Future<int> _createMediciones(String token, String bovinoUuid) async {
    int medicionesCreadas = 0;
    final fechaHoy = DateTime.now();

    try {
      // Solo crear medición si hay al menos un dato morfométrico
      if (_altura != null ||
          _longitudOblicua != null ||
          _longitudCadera != null ||
          _anchoCadera != null ||
          _longitudTorso != null ||
          _edadEstimada != null ||
          _pesoEstimado != null) {
        // Formatear decimales a máximo 6 dígitos totales (4 enteros + 2 decimales)
        final alturaFormateada = _altura != null
            ? double.parse(_altura!.toStringAsFixed(2))
            : null;
        final longitudOblicuaFormateada = _longitudOblicua != null
            ? double.parse(_longitudOblicua!.toStringAsFixed(2))
            : null;
        final longitudCaderaFormateada = _longitudCadera != null
            ? double.parse(_longitudCadera!.toStringAsFixed(2))
            : null;
        final anchoCaderaFormateada = _anchoCadera != null
            ? double.parse(_anchoCadera!.toStringAsFixed(2))
            : null;
        final longitudTorsoFormateada = _longitudTorso != null
            ? double.parse(_longitudTorso!.toStringAsFixed(2))
            : null;
        final pesoEstimadoFormateado = _pesoEstimado != null
            ? double.parse(_pesoEstimado!.toStringAsFixed(2))
            : null;

        final medicionDto = MedicionCreateDto(
          bovinoId: bovinoUuid,
          fecha: fechaHoy,
          alturaCm: alturaFormateada,
          lOblicuaCm: longitudOblicuaFormateada,
          lCaderaCm: longitudCaderaFormateada,
          aCaderaCm: anchoCaderaFormateada,
          lTorsoCm: longitudTorsoFormateada,
          edadMeses: _edadEstimada,
          pesoBasculaKg: pesoEstimadoFormateado,
        );

        await MedicionService.createMedicion(
          token: token,
          medicionData: medicionDto,
        );

        medicionesCreadas = 1;
      } else {
        // No hay datos morfologicos para crear medición
      }
    } catch (e) {
      // No lanzamos excepción aquí para no interrumpir el flujo principal
      // El bovino ya fue creado/encontrado exitosamente
    }

    return medicionesCreadas;
  }

  /// Mantener función original para compatibilidad
  Future<BovinoModel?> registerBovino({
    required String token,
    required String fincaId,
  }) async {
    final result = await registerBovinoWithMediciones(
      token: token,
      fincaId: fincaId,
    );
    return result?['bovino'] as BovinoModel?;
  }

  @override
  void dispose() {
    _bovinoIdController.dispose();
    super.dispose();
  }
}
