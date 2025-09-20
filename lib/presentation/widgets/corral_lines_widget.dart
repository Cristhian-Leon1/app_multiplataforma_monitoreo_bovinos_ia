import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/cattle_pens_provider.dart';

/// CustomPainter para dibujar los puntos de ganado dentro de los corrales
class CattlePointsPainter extends CustomPainter {
  final Map<int, List<Offset>> cattlePoints;
  final bool showPoints;
  final double pointRadius;

  const CattlePointsPainter({
    required this.cattlePoints,
    required this.showPoints,
    this.pointRadius = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showPoints || cattlePoints.isEmpty) return;

    // Colores específicos para cada corral
    final corralColors = {
      1: const Color(0xFF4CAF50), // Verde
      2: const Color(0xFF2196F3), // Azul
      3: const Color(0xFFFF9800), // Naranja
      4: const Color(0xFF9C27B0), // Púrpura
      5: const Color(0xFFF44336), // Rojo
      6: const Color(0xFF00BCD4), // Cian
      7: const Color(0xFF795548), // Marrón
    };

    for (final entry in cattlePoints.entries) {
      final corralId = entry.key;
      final points = entry.value;
      final corralColor = corralColors[corralId] ?? Colors.grey;

      // Paint para los puntos de ganado
      final cattlePaint = Paint()
        ..color = corralColor
        ..style = PaintingStyle.fill;

      // Paint para el borde de los puntos
      final borderPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      for (final point in points) {
        // Dibujar el punto principal
        canvas.drawCircle(point, pointRadius, cattlePaint);
        // Dibujar el borde blanco
        canvas.drawCircle(point, pointRadius, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CattlePointsPainter oldDelegate) {
    return oldDelegate.cattlePoints != cattlePoints ||
        oldDelegate.showPoints != showPoints ||
        oldDelegate.pointRadius != pointRadius;
  }
}

/// CustomPainter para dibujar las líneas de puertas
class GateLinesPainter extends CustomPainter {
  final List<GateConnection> gates;
  final bool showGates;
  final double lineWidth;

  const GateLinesPainter({
    required this.gates,
    required this.showGates,
    this.lineWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showGates || gates.isEmpty) return;

    for (final gate in gates) {
      // Paint para la línea de puerta
      final gatePaint = Paint()
        ..color = gate.color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Dibujar la línea de puerta
      canvas.drawLine(gate.start, gate.end, gatePaint);
    }
  }

  @override
  bool shouldRepaint(GateLinesPainter oldDelegate) {
    return oldDelegate.gates != gates ||
        oldDelegate.showGates != showGates ||
        oldDelegate.lineWidth != lineWidth;
  }
}

/// Widget que combina la imagen del corral con las líneas y puntos de ganado superpuestos
class CorralWithLines extends StatelessWidget {
  final String imagePath;
  final List<LineConnection> lines;
  final bool showLines;
  final Map<int, List<Offset>> cattlePoints;
  final bool showCattlePoints;
  final List<GateConnection> gates;
  final bool showGates;
  final double? width;
  final double? height;

  const CorralWithLines({
    super.key,
    required this.imagePath,
    required this.lines,
    required this.showLines,
    this.cattlePoints = const {},
    this.showCattlePoints = true,
    this.gates = const [],
    this.showGates = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FutureBuilder<Size>(
        future: _getImageSize(imagePath),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          }

          final imageNaturalSize = snapshot.data!;
          return _buildCorralWithAdaptedCoordinates(imageNaturalSize);
        },
      ),
    );
  }

  Widget _buildCorralWithAdaptedCoordinates(Size imageNaturalSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Calcular el tamaño real que ocupará la imagen dentro del contenedor con BoxFit.contain
        final imageDisplaySize = _calculateImageDisplaySize(
          imageNaturalSize,
          containerSize,
        );

        // Calcular el offset para centrar la imagen
        final imageOffset = Offset(
          (containerSize.width - imageDisplaySize.width) / 2,
          (containerSize.height - imageDisplaySize.height) / 2,
        );

        // Ajustar las coordenadas de los puntos de ganado al tamaño real de la imagen
        final adjustedCattlePoints = _adjustCattlePointsToImageSize(
          cattlePoints,
          imageDisplaySize,
          imageOffset,
        );

        // Ajustar las coordenadas de las puertas al tamaño real de la imagen
        final adjustedGates = _adjustGatesToImageSize(
          gates,
          imageDisplaySize,
          imageOffset,
        );

        return Stack(
          children: [
            // Imagen del corral
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  width: width,
                  height: height,
                ),
              ),
            ),

            // Puntos de ganado ajustados al tamaño real de la imagen
            if (showCattlePoints && adjustedCattlePoints.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: CattlePointsPainter(
                    cattlePoints: adjustedCattlePoints,
                    showPoints: showCattlePoints,
                  ),
                ),
              ),

            // Líneas de puertas ajustadas al tamaño real de la imagen
            if (showGates && adjustedGates.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: GateLinesPainter(
                    gates: adjustedGates,
                    showGates: showGates,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Obtiene el tamaño natural de la imagen desde assets
  Future<Size> _getImageSize(String imagePath) async {
    final imageProvider = AssetImage(imagePath);
    final imageStream = imageProvider.resolve(const ImageConfiguration());
    final completer = Completer<Size>();

    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final image = info.image;
        completer.complete(
          Size(image.width.toDouble(), image.height.toDouble()),
        );
      }),
    );

    return completer.future;
  }

  /// Calcula el tamaño que ocupará la imagen dentro del contenedor con BoxFit.contain
  Size _calculateImageDisplaySize(Size imageNaturalSize, Size containerSize) {
    final imageAspectRatio = imageNaturalSize.width / imageNaturalSize.height;
    final containerAspectRatio = containerSize.width / containerSize.height;

    if (imageAspectRatio > containerAspectRatio) {
      // La imagen es más ancha, se ajusta por el ancho
      final displayWidth = containerSize.width;
      final displayHeight = displayWidth / imageAspectRatio;
      return Size(displayWidth, displayHeight);
    } else {
      // La imagen es más alta, se ajusta por la altura
      final displayHeight = containerSize.height;
      final displayWidth = displayHeight * imageAspectRatio;
      return Size(displayWidth, displayHeight);
    }
  }

  /// Ajusta las coordenadas de los puntos de ganado al tamaño real de la imagen
  Map<int, List<Offset>> _adjustCattlePointsToImageSize(
    Map<int, List<Offset>> originalPoints,
    Size imageDisplaySize,
    Offset imageOffset,
  ) {
    final adjustedPoints = <int, List<Offset>>{};

    // Tamaño de referencia original de la imagen (1024x1024 según las coordenadas del provider)
    const double originalImageSize = 1024.0;

    for (final entry in originalPoints.entries) {
      final corralId = entry.key;
      final points = entry.value;

      final adjustedPointList = points.map((point) {
        // Convertir coordenadas absolutas (basadas en 1024x1024) a relativas (0.0 a 1.0)
        final relativeX = point.dx / originalImageSize;
        final relativeY = point.dy / originalImageSize;

        // Escalar al tamaño real de la imagen mostrada y añadir el offset de centrado
        final adjustedX = (relativeX * imageDisplaySize.width) + imageOffset.dx;
        final adjustedY =
            (relativeY * imageDisplaySize.height) + imageOffset.dy;

        return Offset(adjustedX, adjustedY);
      }).toList();

      adjustedPoints[corralId] = adjustedPointList;
    }

    return adjustedPoints;
  }

  /// Ajusta las coordenadas de las puertas al tamaño real de la imagen
  List<GateConnection> _adjustGatesToImageSize(
    List<GateConnection> originalGates,
    Size imageDisplaySize,
    Offset imageOffset,
  ) {
    // Tamaño de referencia original de la imagen (1024x1024 según las coordenadas del provider)
    const double originalImageSize = 1024.0;

    return originalGates.map((gate) {
      // Convertir coordenadas absolutas a relativas y luego escalar
      final relativeStartX = gate.start.dx / originalImageSize;
      final relativeStartY = gate.start.dy / originalImageSize;
      final relativeEndX = gate.end.dx / originalImageSize;
      final relativeEndY = gate.end.dy / originalImageSize;

      final adjustedStart = Offset(
        (relativeStartX * imageDisplaySize.width) + imageOffset.dx,
        (relativeStartY * imageDisplaySize.height) + imageOffset.dy,
      );

      final adjustedEnd = Offset(
        (relativeEndX * imageDisplaySize.width) + imageOffset.dx,
        (relativeEndY * imageDisplaySize.height) + imageOffset.dy,
      );

      return GateConnection(
        start: adjustedStart,
        end: adjustedEnd,
        id: gate.id, // Preservar el ID original
        color: gate.color,
      );
    }).toList();
  }
}
