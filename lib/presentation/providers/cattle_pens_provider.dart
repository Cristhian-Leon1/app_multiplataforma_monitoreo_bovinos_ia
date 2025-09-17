import 'package:flutter/material.dart';
import 'dart:math' as math;

class CattlePensProvider extends ChangeNotifier {
  // Coordenadas de los puntos del Corral 1 (imagen original 1024x1024)
  static const List<Offset> _corral1Points = [
    Offset(257, 762), // Punto 1
    Offset(294, 819), // Punto 2
    Offset(396, 832), // Punto 3
    Offset(449, 668), // Punto 4
    Offset(339, 576), // Punto 5
    Offset(200, 646), // Punto 6
    Offset(208, 718), // Punto 7
  ];

  // Coordenadas de los puntos del Corral 2 (imagen original 1024x1024)
  static const List<Offset> _corral2Points = [
    Offset(121, 503), // Punto 8
    Offset(121, 579), // Punto 9
    Offset(171, 645), // Punto 10
    Offset(331, 556), // Punto 11
    Offset(308, 433), // Punto 12
    Offset(161, 368), // Punto 13
    Offset(116, 444), // Punto 14
  ];

  // Coordenadas de los puntos del Corral 3 (imagen original 1024x1024)
  static const List<Offset> _corral3Points = [
    Offset(215, 225), // Punto 15
    Offset(183, 254), // Punto 16
    Offset(177, 357), // Punto 17
    Offset(308, 412), // Punto 18
    Offset(412, 311), // Punto 19
    Offset(352, 173), // Punto 20
    Offset(235, 190), // Punto 21
  ];

  // Coordenadas de los puntos del Corral 4 (imagen original 1024x1024)
  static const List<Offset> _corral4Points = [
    Offset(505, 110), // Punto 22
    Offset(465, 103), // Punto 23
    Offset(380, 170), // Punto 24
    Offset(431, 303), // Punto 25
    Offset(578, 304), // Punto 26
    Offset(630, 166), // Punto 27
    Offset(545, 101), // Punto 28
  ];

  // Coordenadas de los puntos del Corral 5 (imagen original 1024x1024)
  static const List<Offset> _corral5Points = [
    Offset(796, 230), // Punto 29
    Offset(769, 187), // Punto 30
    Offset(660, 175), // Punto 31
    Offset(600, 305), // Punto 32
    Offset(701, 410), // Punto 33
    Offset(846, 357), // Punto 34
    Offset(838, 268), // Punto 35
  ];

  // Coordenadas de los puntos del Corral 6 (imagen original 1024x1024)
  static const List<Offset> _corral6Points = [
    Offset(899, 508), // Punto 36
    Offset(903, 441), // Punto 37
    Offset(857, 373), // Punto 38
    Offset(706, 431), // Punto 39
    Offset(689, 556), // Punto 40
    Offset(849, 646), // Punto 41
    Offset(902, 572), // Punto 42
  ];

  // Coordenadas de los puntos del Corral 7 (imagen original 1024x1024)
  static const List<Offset> _corral7Points = [
    Offset(773, 779), // Punto 43
    Offset(814, 746), // Punto 44
    Offset(828, 654), // Punto 45
    Offset(686, 578), // Punto 46
    Offset(577, 666), // Punto 47
    Offset(622, 830), // Punto 48
    Offset(747, 821), // Punto 49
  ];

  // Tamaño original de la imagen
  static const double _originalImageSize = 1024.0;

  // Estado de visibilidad de las líneas
  bool _showCorralLines = true;
  bool _showCorral1Lines = true;
  bool _showCorral2Lines = true;
  bool _showCorral3Lines = true;
  bool _showCorral4Lines = true;
  bool _showCorral5Lines = true;
  bool _showCorral6Lines = true;
  bool _showCorral7Lines = true;

  // Getters
  bool get showCorralLines => _showCorralLines;
  bool get showCorral1Lines => _showCorral1Lines;
  bool get showCorral2Lines => _showCorral2Lines;
  bool get showCorral3Lines => _showCorral3Lines;
  bool get showCorral4Lines => _showCorral4Lines;
  bool get showCorral5Lines => _showCorral5Lines;
  bool get showCorral6Lines => _showCorral6Lines;
  bool get showCorral7Lines => _showCorral7Lines;
  List<Offset> get corral1Points => _corral1Points;
  List<Offset> get corral2Points => _corral2Points;
  List<Offset> get corral3Points => _corral3Points;
  List<Offset> get corral4Points => _corral4Points;
  List<Offset> get corral5Points => _corral5Points;
  List<Offset> get corral6Points => _corral6Points;
  List<Offset> get corral7Points => _corral7Points;
  double get originalImageSize => _originalImageSize;

  /// Obtener las líneas de conexión del corral 1
  List<LineConnection> getCorral1Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral1Points.length; i++) {
      final currentPoint = _corral1Points[i];
      final nextPoint = _corral1Points[(i + 1) % _corral1Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 1,
          corralId: 1,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 2
  List<LineConnection> getCorral2Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral2Points.length; i++) {
      final currentPoint = _corral2Points[i];
      final nextPoint = _corral2Points[(i + 1) % _corral2Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 8, // Continuar numeración desde el punto 8
          corralId: 2,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 3
  List<LineConnection> getCorral3Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral3Points.length; i++) {
      final currentPoint = _corral3Points[i];
      final nextPoint = _corral3Points[(i + 1) % _corral3Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 15, // Continuar numeración desde el punto 15
          corralId: 3,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 4
  List<LineConnection> getCorral4Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral4Points.length; i++) {
      final currentPoint = _corral4Points[i];
      final nextPoint = _corral4Points[(i + 1) % _corral4Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 22, // Continuar numeración desde el punto 22
          corralId: 4,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 5
  List<LineConnection> getCorral5Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral5Points.length; i++) {
      final currentPoint = _corral5Points[i];
      final nextPoint = _corral5Points[(i + 1) % _corral5Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 29, // Continuar numeración desde el punto 29
          corralId: 5,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 6
  List<LineConnection> getCorral6Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral6Points.length; i++) {
      final currentPoint = _corral6Points[i];
      final nextPoint = _corral6Points[(i + 1) % _corral6Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 36, // Continuar numeración desde el punto 36
          corralId: 6,
        ),
      );
    }

    return lines;
  }

  /// Obtener las líneas de conexión del corral 7
  List<LineConnection> getCorral7Lines() {
    final lines = <LineConnection>[];

    for (int i = 0; i < _corral7Points.length; i++) {
      final currentPoint = _corral7Points[i];
      final nextPoint = _corral7Points[(i + 1) % _corral7Points.length];

      lines.add(
        LineConnection(
          start: currentPoint,
          end: nextPoint,
          pointNumber: i + 43, // Continuar numeración desde el punto 43
          corralId: 7,
        ),
      );
    }

    return lines;
  }

  /// Obtener todas las líneas de todos los corrales
  List<LineConnection> getAllLines() {
    final allLines = <LineConnection>[];

    if (_showCorral1Lines) {
      allLines.addAll(getCorral1Lines());
    }

    if (_showCorral2Lines) {
      allLines.addAll(getCorral2Lines());
    }

    if (_showCorral3Lines) {
      allLines.addAll(getCorral3Lines());
    }

    if (_showCorral4Lines) {
      allLines.addAll(getCorral4Lines());
    }

    if (_showCorral5Lines) {
      allLines.addAll(getCorral5Lines());
    }

    if (_showCorral6Lines) {
      allLines.addAll(getCorral6Lines());
    }

    if (_showCorral7Lines) {
      allLines.addAll(getCorral7Lines());
    }

    return allLines;
  }

  /// Escalar las coordenadas según el tamaño actual de la imagen
  List<Offset> getScaledPoints(double currentSize) {
    final scaleFactor = currentSize / _originalImageSize;

    return _corral1Points
        .map((point) => Offset(point.dx * scaleFactor, point.dy * scaleFactor))
        .toList();
  }

  /// Escalar las líneas según el tamaño actual de la imagen
  List<LineConnection> getScaledLines(double currentSize) {
    final scaleFactor = currentSize / _originalImageSize;
    final lines = getAllLines();

    return lines
        .map(
          (line) => LineConnection(
            start: Offset(
              line.start.dx * scaleFactor,
              line.start.dy * scaleFactor,
            ),
            end: Offset(line.end.dx * scaleFactor, line.end.dy * scaleFactor),
            pointNumber: line.pointNumber,
            corralId: line.corralId,
          ),
        )
        .toList();
  }

  /// Generar puntos aleatorios dentro de un polígono definido por una lista de puntos
  List<Offset> _generatePointsInPolygon(List<Offset> polygonPoints, int count) {
    if (count <= 0) return [];

    final random = math.Random();
    final generatedPoints = <Offset>[];

    // Encontrar el bounding box del polígono
    double minX = polygonPoints.map((p) => p.dx).reduce(math.min);
    double maxX = polygonPoints.map((p) => p.dx).reduce(math.max);
    double minY = polygonPoints.map((p) => p.dy).reduce(math.min);
    double maxY = polygonPoints.map((p) => p.dy).reduce(math.max);

    int attempts = 0;
    final maxAttempts = count * 100; // Evitar bucles infinitos

    while (generatedPoints.length < count && attempts < maxAttempts) {
      // Generar punto aleatorio dentro del bounding box
      final x = minX + random.nextDouble() * (maxX - minX);
      final y = minY + random.nextDouble() * (maxY - minY);
      final point = Offset(x, y);

      // Verificar si el punto está dentro del polígono
      if (_isPointInPolygon(point, polygonPoints)) {
        generatedPoints.add(point);
      }

      attempts++;
    }

    return generatedPoints;
  }

  /// Verificar si un punto está dentro de un polígono usando el algoritmo de ray casting
  bool _isPointInPolygon(Offset point, List<Offset> polygonPoints) {
    if (polygonPoints.length < 3) return false;

    bool inside = false;
    int j = polygonPoints.length - 1;

    for (int i = 0; i < polygonPoints.length; i++) {
      if (((polygonPoints[i].dy > point.dy) !=
              (polygonPoints[j].dy > point.dy)) &&
          (point.dx <
              (polygonPoints[j].dx - polygonPoints[i].dx) *
                      (point.dy - polygonPoints[i].dy) /
                      (polygonPoints[j].dy - polygonPoints[i].dy) +
                  polygonPoints[i].dx)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  /// Generar puntos para todos los corrales basado en las cantidades de bovinos
  Map<int, List<Offset>> generateCattlePoints(
    Map<String, int> rangosEdad,
    double currentSize,
  ) {
    final scaleFactor = currentSize / _originalImageSize;
    final cattlePoints = <int, List<Offset>>{};

    // Mapear rangos de edad a corrales
    final counts = [
      rangosEdad['0-6 meses'] ?? 0, // Corral 1
      rangosEdad['7-12 meses'] ?? 0, // Corral 2
      rangosEdad['13-24 meses'] ?? 0, // Corral 3
      rangosEdad['25-36 meses'] ?? 0, // Corral 4
      rangosEdad['37-48 meses'] ?? 0, // Corral 5
      rangosEdad['49-60 meses'] ?? 0, // Corral 6
      rangosEdad['Mayores a 60 meses'] ?? 0, // Corral 7
    ];

    final corralPoints = [
      _corral1Points,
      _corral2Points,
      _corral3Points,
      _corral4Points,
      _corral5Points,
      _corral6Points,
      _corral7Points,
    ];

    for (int i = 0; i < corralPoints.length; i++) {
      final corralId = i + 1;
      final count = counts[i];

      if (count > 0) {
        // Generar puntos para este corral
        final points = _generatePointsInPolygon(corralPoints[i], count);

        // Escalar los puntos al tamaño actual
        final scaledPoints = points
            .map(
              (point) => Offset(point.dx * scaleFactor, point.dy * scaleFactor),
            )
            .toList();

        cattlePoints[corralId] = scaledPoints;
      }
    }

    return cattlePoints;
  }

  /// Alternar la visibilidad de las líneas del corral
  void toggleCorralLines() {
    _showCorralLines = !_showCorralLines;
    notifyListeners();
  }

  /// Alternar la visibilidad de las líneas de cada corral individual
  void toggleCorral1Lines() {
    _showCorral1Lines = !_showCorral1Lines;
    notifyListeners();
  }

  void toggleCorral2Lines() {
    _showCorral2Lines = !_showCorral2Lines;
    notifyListeners();
  }

  void toggleCorral3Lines() {
    _showCorral3Lines = !_showCorral3Lines;
    notifyListeners();
  }

  void toggleCorral4Lines() {
    _showCorral4Lines = !_showCorral4Lines;
    notifyListeners();
  }

  void toggleCorral5Lines() {
    _showCorral5Lines = !_showCorral5Lines;
    notifyListeners();
  }

  void toggleCorral6Lines() {
    _showCorral6Lines = !_showCorral6Lines;
    notifyListeners();
  }

  void toggleCorral7Lines() {
    _showCorral7Lines = !_showCorral7Lines;
    notifyListeners();
  }

  /// Mostrar/Ocultar todas las líneas
  void showAllLines() {
    _showCorralLines = true;
    _showCorral1Lines = true;
    _showCorral2Lines = true;
    _showCorral3Lines = true;
    _showCorral4Lines = true;
    _showCorral5Lines = true;
    _showCorral6Lines = true;
    _showCorral7Lines = true;
    notifyListeners();
  }

  void hideAllLines() {
    _showCorralLines = false;
    _showCorral1Lines = false;
    _showCorral2Lines = false;
    _showCorral3Lines = false;
    _showCorral4Lines = false;
    _showCorral5Lines = false;
    _showCorral6Lines = false;
    _showCorral7Lines = false;
    notifyListeners();
  }
}

/// Clase para representar una conexión entre dos puntos
class LineConnection {
  final Offset start;
  final Offset end;
  final int pointNumber;
  final int corralId;

  const LineConnection({
    required this.start,
    required this.end,
    required this.pointNumber,
    required this.corralId,
  });

  @override
  String toString() {
    return 'LineConnection(corral $corralId, punto $pointNumber: $start -> $end)';
  }
}
