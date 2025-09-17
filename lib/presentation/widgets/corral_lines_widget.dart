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

/// Widget que combina la imagen del corral con las líneas y puntos de ganado superpuestos
class CorralWithLines extends StatelessWidget {
  final String imagePath;
  final List<LineConnection> lines;
  final bool showLines;
  final Map<int, List<Offset>> cattlePoints;
  final bool showCattlePoints;
  final double? width;
  final double? height;

  const CorralWithLines({
    super.key,
    required this.imagePath,
    required this.lines,
    required this.showLines,
    this.cattlePoints = const {},
    this.showCattlePoints = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
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

          // Puntos de ganado
          if (showCattlePoints && cattlePoints.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: CattlePointsPainter(
                  cattlePoints: cattlePoints,
                  showPoints: showCattlePoints,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
