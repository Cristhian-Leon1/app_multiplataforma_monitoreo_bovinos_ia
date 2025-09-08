import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../data/models/pose_model.dart';

/// Widget para mostrar imagen con keypoints dibujados
class PoseResultImageWidget extends StatelessWidget {
  final PoseAnalysisResult result;

  const PoseResultImageWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImageFromBytes(result.resizedImageBytes),
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

        return AspectRatio(
          aspectRatio: image.width / image.height,
          child: CustomPaint(
            painter: KeypointsPainter(
              image: image,
              detections: result.prediction.detections,
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }
}

/// CustomPainter para dibujar keypoints sobre la imagen
class KeypointsPainter extends CustomPainter {
  final ui.Image image;
  final List<PoseDetection> detections;

  KeypointsPainter({required this.image, required this.detections});

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

    for (final detection in detections) {
      for (int i = 0; i < detection.keypoints.length; i++) {
        final keypoint = detection.keypoints[i];

        // Solo dibujar keypoints con confianza alta
        if (keypoint.confidence > 0.5) {
          // Las coordenadas vienen directamente de la imagen procesada
          // Solo necesitamos aplicar el factor de escala del widget
          final x = (keypoint.x * scaleX) + offsetX;
          final y = (keypoint.y * scaleY) + offsetY;

          // Asegurar que las coordenadas estén dentro del widget
          final clampedX = x.clamp(8.0, size.width - 8.0).toDouble();
          final clampedY = y.clamp(8.0, size.height - 8.0).toDouble();

          // Dibujar círculo para keypoint
          final paint = Paint()
            ..color = _getKeypointColor(i)
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
              text: '$i',
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

          // Dibujar información de confianza cerca del keypoint
          final confidenceText = TextPainter(
            text: TextSpan(
              text: '${(keypoint.confidence * 100).round()}%',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            textDirection: TextDirection.ltr,
          );

          confidenceText.layout();

          // Dibujar fondo blanco para el texto de confianza
          final confidenceBg = Paint()
            ..color = Colors.white.withOpacity(0.8)
            ..style = PaintingStyle.fill;

          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                clampedX + 12,
                clampedY - 8,
                confidenceText.width + 4,
                confidenceText.height + 2,
              ),
              const Radius.circular(4),
            ),
            confidenceBg,
          );

          confidenceText.paint(canvas, Offset(clampedX + 14, clampedY - 7));
        }
      }
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
  ) {
    // Conectar keypoints secuencialmente
    for (int i = 0; i < keypoints.length - 1; i++) {
      final keypoint1 = keypoints[i];
      final keypoint2 = keypoints[i + 1];

      // Solo dibujar líneas entre keypoints con confianza alta
      if (keypoint1.confidence > 0.5 && keypoint2.confidence > 0.5) {
        final x1 = (keypoint1.x * scaleX) + offsetX;
        final y1 = (keypoint1.y * scaleY) + offsetY;
        final x2 = (keypoint2.x * scaleX) + offsetX;
        final y2 = (keypoint2.y * scaleY) + offsetY;

        final linePaint = Paint()
          ..color = Colors.blue.withOpacity(0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
      }
    }
  }

  Color _getKeypointColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.lime,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.brown,
      Colors.deepOrange,
      Colors.deepPurple,
      Colors.lightBlue,
      Colors.lightGreen,
    ];

    return colors[index % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

/// Diálogo para mostrar resultados de análisis de pose
class PoseResultsDialog extends StatelessWidget {
  final List<PoseAnalysisResult> results;

  const PoseResultsDialog({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    'Resultados del Análisis de Pose',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay resultados para mostrar',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: results
                            .map((result) => _buildResultCard(result))
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(PoseAnalysisResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              'Imagen ${result.imageType.toUpperCase()}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Imagen con keypoints
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PoseResultImageWidget(result: result),
              ),
            ),
            const SizedBox(height: 16),

            // Información de detecciones
            Text(
              'Detecciones: ${result.prediction.detections.length}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            // Lista de detecciones
            ...result.prediction.detections.map(
              (detection) => _buildDetectionInfo(detection),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionInfo(PoseDetection detection) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Clase: ${detection.className}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Keypoints: ${detection.keypoints.length}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Confianza promedio: ${_getAverageConfidence(detection.keypoints).toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  double _getAverageConfidence(List<Keypoint> keypoints) {
    if (keypoints.isEmpty) return 0.0;

    final sum = keypoints.fold<double>(
      0.0,
      (prev, keypoint) => prev + keypoint.confidence,
    );

    return (sum / keypoints.length) * 100;
  }
}
