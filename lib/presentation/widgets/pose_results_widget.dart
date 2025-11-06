import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/pose_model.dart';
import '../../data/models/bovino_model.dart';
import '../providers/cattle_identification_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/auth_provider.dart';

/// Widget para mostrar imagen con keypoints dibujados
class PoseResultImageWidget extends StatefulWidget {
  final PoseAnalysisResult result;

  const PoseResultImageWidget({super.key, required this.result});

  @override
  State<PoseResultImageWidget> createState() => _PoseResultImageWidgetState();
}

class _PoseResultImageWidgetState extends State<PoseResultImageWidget> {
  bool _measuresCalculated = false;

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImageFromBytes(widget.result.resizedImageBytes),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No se pudo cargar la imagen'));
        }

        final image = snapshot.data!;

        return Consumer<CattleIdentificationProvider>(
          builder: (context, provider, child) {
            // Calcular medidas morfométricas solo una vez
            if (!_measuresCalculated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _calculateMorphometricMeasures(provider);
                _measuresCalculated = true;
              });
            }

            return AspectRatio(
              aspectRatio: image.width / image.height,
              child: CustomPaint(
                painter: KeypointsPainter(
                  image: image,
                  detections: widget.result.prediction.detections,
                ),
                child: Container(),
              ),
            );
          },
        );
      },
    );
  }

  /// Calcular medidas morfométricas de forma segura
  void _calculateMorphometricMeasures(CattleIdentificationProvider provider) {
    for (final detection in widget.result.prediction.detections) {
      final keypoints = detection.keypoints;

      if (detection.className == 'bovino_lateral') {
        // Mapeo de índices para bovino lateral:
        // 0: C, 1: D, 2: B, 3: A, 4: G, 5: E, 6: F

        if (keypoints.length >= 7) {
          // Caso completo: tenemos todos los puntos A-G

          // Calcular todas las distancias
          final altura = _calculateDistance(keypoints[0], keypoints[1]); // C-D
          final longitudOblicua = _calculateDistance(
            keypoints[2],
            keypoints[3],
          ); // B-A
          final longitudCadera = _calculateDistance(
            keypoints[3],
            keypoints[4],
          ); // A-G
          final longitudTorso = _calculateDistance(
            keypoints[5],
            keypoints[6],
          ); // E-F

          final alturaCentimetos = altura / 3.35;
          final longitudOblicuaCentimetros = longitudOblicua / 3.35;
          final longitudCaderaCentimetros = longitudCadera / 3.35;
          final longitudTorsoCentimetros = longitudTorso / 3.35;

          // Actualizar variable B para cálculo de peso
          final variableB = longitudTorsoCentimetros / 2;
          provider.updateWeightVariables(variableB: variableB);
          // Actualizar el provider
          provider.updateMorphometricMeasures(
            altura: alturaCentimetos,
            longitudOblicua: longitudOblicuaCentimetros,
            longitudCadera: longitudCaderaCentimetros,
            longitudTorso: longitudTorsoCentimetros,
          );
        } else if (keypoints.length >= 2) {
          // Caso limitado: solo tenemos C y D
          final anchoCadera = _calculateDistance(
            keypoints[0],
            keypoints[1],
          ); // C-D

          final anchoCaderaCentimetros = anchoCadera / 5.8;
          // Actualizar variable A para cálculo de peso
          final variableA = anchoCaderaCentimetros / 2;
          provider.updateWeightVariables(variableA: variableA);

          provider.updateMorphometricMeasures(
            anchoCadera: anchoCaderaCentimetros,
          );
        }
      } else if (detection.className == 'bovino_posterior') {
        // Mapeo de índices para bovino posterior:
        // 0: H, 1: I

        if (keypoints.length >= 2) {
          final anchoCadera = _calculateDistance(
            keypoints[0],
            keypoints[1],
          ); // H-I

          final anchoCaderaCentimetros = anchoCadera / 5.8;
          // Actualizar variable A para cálculo de peso
          final variableA = anchoCaderaCentimetros / 2;
          provider.updateWeightVariables(variableA: variableA);

          provider.updateMorphometricMeasures(
            anchoCadera: anchoCaderaCentimetros,
          );
        }
      }
    }
  }

  /// Calcular distancia euclidiana entre dos keypoints
  double _calculateDistance(Keypoint p1, Keypoint p2) {
    final dx = p1.x - p2.x;
    final dy = p1.y - p2.y;
    return sqrt(dx * dx + dy * dy);
  }
}

/// CustomPainter para dibujar keypoints sobre la imagen
class KeypointsPainter extends CustomPainter {
  final ui.Image image;
  final List<PoseDetection> detections;

  KeypointsPainter({required this.image, required this.detections});

  final List<String> keypointLabelsLateral = [
    "C",
    "D",
    "B",
    "A",
    "G",
    "E",
    "F",
  ];
  final List<String> keypointLabelsPosterior = ["H", "I"];

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar la imagen de fondo escalada para llenar el widget
    _drawImageBackground(canvas, size);

    // Dibujar keypoints usando las coordenadas exactas de la API
    _drawKeypoints(canvas, size);
  }

  void _drawImageBackground(Canvas canvas, Size size) {
    // Calcular el rectángulo destino manteniendo la proporción
    final imageAspectRatio = image.width / image.height;
    final widgetAspectRatio = size.width / size.height;

    Rect destRect;
    if (imageAspectRatio > widgetAspectRatio) {
      // La imagen es más ancha, ajustar por ancho
      final scaledHeight = size.width / imageAspectRatio;
      final offsetY = (size.height - scaledHeight) / 2;
      destRect = Rect.fromLTWH(0, offsetY, size.width, scaledHeight);
    } else {
      // La imagen es más alta, ajustar por alto
      final scaledWidth = size.height * imageAspectRatio;
      final offsetX = (size.width - scaledWidth) / 2;
      destRect = Rect.fromLTWH(offsetX, 0, scaledWidth, size.height);
    }

    // Dibujar la imagen
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      destRect,
      Paint(),
    );
  }

  void _drawKeypoints(Canvas canvas, Size size) {
    // Calcular el factor de escala entre la imagen y el widget
    final imageAspectRatio = image.width / image.height;
    final widgetAspectRatio = size.width / size.height;

    double scaleX, scaleY, offsetX = 0, offsetY = 0;

    if (imageAspectRatio > widgetAspectRatio) {
      // La imagen es más ancha, ajustar por ancho
      scaleX = size.width / image.width;
      scaleY = scaleX;
      offsetY = (size.height - (image.height * scaleY)) / 2;
    } else {
      // La imagen es más alta, ajustar por alto
      scaleY = size.height / image.height;
      scaleX = scaleY;
      offsetX = (size.width - (image.width * scaleX)) / 2;
    }

    // Dibujar líneas conectando keypoints si hay más de uno
    if (detections.isNotEmpty) {
      for (final detection in detections) {
        if (detection.keypoints.length > 1) {
          _drawKeypointConnections(
            canvas,
            detection.keypoints,
            scaleX,
            scaleY,
            offsetX,
            offsetY,
            detection.className,
          );
        }
      }
    }

    for (final detection in detections) {
      for (int i = 0; i < detection.keypoints.length; i++) {
        final keypoint = detection.keypoints[i];

        // Solo dibujar keypoints con confianza alta
        if (keypoint.confidence > 0.7) {
          // Las coordenadas vienen directamente de la imagen procesada
          // Solo necesitamos aplicar el factor de escala del widget
          final x = (keypoint.x * scaleX) + offsetX;
          final y = (keypoint.y * scaleY) + offsetY;

          // Asegurar que las coordenadas estén dentro del widget
          final clampedX = x.clamp(8.0, size.width - 8.0).toDouble();
          final clampedY = y.clamp(8.0, size.height - 8.0).toDouble();

          // Dibujar círculo para keypoint
          final paint = Paint()
            ..color = detection.className == 'bovino_lateral'
                ? _getKeypointColorLateral(i)
                : _getKeypointColorPosterior(i)
            ..style = PaintingStyle.fill;

          canvas.drawCircle(Offset(clampedX, clampedY), 8.0, paint);

          // Dibujar borde del círculo
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;

          canvas.drawCircle(Offset(clampedX, clampedY), 8.0, borderPaint);

          // Dibujar texto con índice del keypoint
          final textPainter = TextPainter(
            text: TextSpan(
              text: detection.className == 'bovino_lateral'
                  ? keypointLabelsLateral[i]
                  : keypointLabelsPosterior[i],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );

          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(
              clampedX - textPainter.width / 2,
              clampedY - textPainter.height / 2,
            ),
          );
        }
      }
    }
  }

  void _drawKeypointConnections(
    Canvas canvas,
    List<Keypoint> keypoints,
    double scaleX,
    double scaleY,
    double offsetX,
    double offsetY,
    String className,
  ) {
    // Función auxiliar: convierte un keypoint a Offset
    Offset toOffset(keypoint) {
      return Offset(
        (keypoint.x * scaleX) + offsetX,
        (keypoint.y * scaleY) + offsetY,
      );
    }

    // Estilo de línea
    final linePaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    if (className == 'bovino_lateral') {
      // Mapeo de índices para bovino lateral:
      // 0: C, 1: D, 2: B, 3: A, 4: G, 5: E, 6: F

      if (keypoints.length >= 7) {
        // Caso completo: tenemos todos los puntos A-G
        final connections = [
          [0, 1], // C-D (altura)
          [2, 3], // B-A (longitud oblicua)
          [3, 4], // A-G (longitud cadera)
          [5, 6], // E-F (longitud torso)
        ];

        for (var pair in connections) {
          final i1 = pair[0];
          final i2 = pair[1];

          if (i1 < keypoints.length && i2 < keypoints.length) {
            final p1 = toOffset(keypoints[i1]);
            final p2 = toOffset(keypoints[i2]);
            canvas.drawLine(p1, p2, linePaint);
          }
        }
      } else if (keypoints.length >= 2) {
        // Caso limitado: solo tenemos C y D
        final p1 = toOffset(keypoints[0]); // C
        final p2 = toOffset(keypoints[1]); // D
        canvas.drawLine(p1, p2, linePaint);
      }
    } else if (className == 'bovino_posterior') {
      // Mapeo de índices para bovino posterior:
      // 0: H, 1: I

      if (keypoints.length >= 2) {
        final p1 = toOffset(keypoints[0]); // H
        final p2 = toOffset(keypoints[1]); // I
        canvas.drawLine(p1, p2, linePaint);
      }
    }
  }

  Color _getKeypointColorLateral(int index) {
    // Colores diferentes para cada keypoint
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.red,
      Colors.yellow,
      Colors.green,
    ];

    return colors[index % colors.length];
  }

  Color _getKeypointColorPosterior(int index) {
    // Colores diferentes para cada keypoint
    final colors = [Colors.orange, Colors.blue];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Dialog para mostrar resultados de análisis
class PoseResultsDialog extends StatelessWidget {
  final List<PoseAnalysisResult> results;

  PoseResultsDialog({super.key, required this.results});

  final List<String> titlesResults = [
    "ID de bovino",
    "Sexo",
    "Raza",
    "Altura (D -> C)",
    "Longitud oblicua (B -> A)",
    "Longitud cadera (A -> G)",
    "Ancho cadera (H -> I)",
    "Longitud torso (E -> F)",
    "Peso calculado",
    "Edad estimada",
  ];

  @override
  Widget build(BuildContext context) {
    var analisisProvider = Provider.of<CattleIdentificationProvider>(context);

    final List<String> identificationResults = [
      analisisProvider.bovinoIdController.text,
      analisisProvider.selectedSex ?? 'N/A',
      analisisProvider.selectedBreed ?? 'N/A',
      analisisProvider.altura?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.longitudOblicua?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.longitudCadera?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.anchoCadera?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.longitudTorso?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.pesoEstimado?.toStringAsFixed(2) ?? 'N/A',
      analisisProvider.edadEstimada?.toString() ?? 'N/A',
    ];

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Resultados de Análisis',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Contenido con scroll
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < results.length; i++) ...[
                      _buildResultCard(context, results[i]),
                      const SizedBox(height: 10),
                    ],
                    for (int i = 0; i < titlesResults.length; i++) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 5, top: 5),
                        child: _buildTextResults(
                          context: context,
                          textTitle: "${titlesResults[i]}: ",
                          textResult: i < identificationResults.length
                              ? (i <= 2
                                    ? identificationResults[i]
                                    : i >= 3 && i <= 7
                                    ? "${identificationResults[i]} ${i == 6 ? 'cms' : 'cms'}"
                                    : i == 8
                                    ? "${identificationResults[i]} kg"
                                    : "${identificationResults[i]} meses")
                              : "N/A",
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),

            // Botones de acción
            const SizedBox(height: 16),
            Consumer2<CattleIdentificationProvider, StatisticsProvider>(
              builder: (context, cattleProvider, statisticsProvider, child) {
                return Column(
                  children: [
                    // Botón de registrar datos
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: cattleProvider.isRegistering
                            ? null
                            : () => _handleRegisterBovino(
                                context,
                                cattleProvider,
                                statisticsProvider,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: cattleProvider.isRegistering
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Registrando...'),
                                ],
                              )
                            : const Text('Registrar Datos'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón de cerrar
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cerrar',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, PoseAnalysisResult result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Imagen ${result.imageType.toUpperCase()}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 12),

            // Imagen con keypoints
            Container(
              width: double.infinity,
              height: 231,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4CAF50)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PoseResultImageWidget(result: result),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildTextResults({
    required BuildContext context,
    required String textTitle,
    required String textResult,
  }) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: textTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: textResult,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Manejar el registro del bovino con mediciones
  Future<void> _handleRegisterBovino(
    BuildContext context,
    CattleIdentificationProvider cattleProvider,
    StatisticsProvider statisticsProvider,
  ) async {
    try {
      // Obtener el AuthProvider para el token
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.userToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró token de autenticación'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Verificar que haya una finca seleccionada
      if (statisticsProvider.selectedFinca == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Debe seleccionar una finca'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Intentar registrar el bovino con mediciones
      final result = await cattleProvider.registerBovinoWithMediciones(
        token: authProvider.userToken!,
        fincaId: statisticsProvider.selectedFinca!.id,
      );

      if (result != null) {
        final bovino = result['bovino'] as BovinoModel;
        final bovinoCreated = result['bovinoCreated'] as bool;
        final medicionesCount = result['medicionesCount'] as int;

        // Construir mensaje según lo que pasó
        String message;
        if (bovinoCreated) {
          message = 'Bovino "${bovino.idBovino}" registrado exitosamente';
        } else {
          message = 'Se encontró bovino existente "${bovino.idBovino}"';
        }

        if (medicionesCount > 0) {
          message += ' y se registraron $medicionesCount mediciones';
        }

        // OPTIMIZACIÓN: Respuesta inmediata al usuario
        // 1. Mostrar feedback inmediato
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✓ $message',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // 2. Cerrar diálogo inmediatamente
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // 3. Limpiar formulario inmediatamente para próximo uso
        cattleProvider.clearForm();

        // 4. Actualizar estadísticas en background sin bloquear UI
        statisticsProvider
            .initializeData(authProvider.userToken!)
            .then((_) {
              print('✓ Estadísticas actualizadas correctamente');
            })
            .catchError((error) {
              print('❌ Error al actualizar estadísticas: $error');
            });
      } else {
        // Error - El mensaje ya fue manejado en el provider
        // Solo mostrar el error si hay uno
        if (cattleProvider.errorMessage != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cattleProvider.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
