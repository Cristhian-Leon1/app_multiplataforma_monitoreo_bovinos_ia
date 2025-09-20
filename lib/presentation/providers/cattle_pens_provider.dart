import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:async';

class CattlePensProvider extends ChangeNotifier {
  // Coordenadas de los puntos del Corral 1 (imagen original 1024x1024)
  static const List<Offset> _corral1Points = [
    Offset(257, 762), // Punto 1
    Offset(294, 819), // Punto 2
    Offset(396, 832), // Punto 3
    Offset(449, 668), // Punto 4
    Offset(339, 582), // Punto 5
    Offset(200, 646), // Punto 6
    Offset(208, 718), // Punto 7
  ];

  // Coordenadas de los puntos del Corral 2 (imagen original 1024x1024)
  static const List<Offset> _corral2Points = [
    Offset(121, 503), // Punto 8
    Offset(121, 579), // Punto 9
    Offset(171, 645), // Punto 10
    Offset(331, 556), // Punto 11
    Offset(303, 435), // Punto 12
    Offset(161, 368), // Punto 13
    Offset(116, 444), // Punto 14
  ];

  // Coordenadas de los puntos del Corral 3 (imagen original 1024x1024)
  static const List<Offset> _corral3Points = [
    Offset(215, 225), // Punto 15
    Offset(183, 254), // Punto 16
    Offset(177, 357), // Punto 17
    Offset(308, 412), // Punto 18
    Offset(409, 315), // Punto 19
    Offset(352, 173), // Punto 20
    Offset(235, 190), // Punto 21
  ];

  // Coordenadas de los puntos del Corral 4 (imagen original 1024x1024)
  static const List<Offset> _corral4Points = [
    Offset(505, 110), // Punto 22
    Offset(465, 103), // Punto 23
    Offset(380, 170), // Punto 24
    Offset(431, 303), // Punto 25
    Offset(578, 310), // Punto 26
    Offset(630, 166), // Punto 27
    Offset(545, 101), // Punto 28
  ];

  // Coordenadas de los puntos del Corral 5 (imagen original 1024x1024)
  static const List<Offset> _corral5Points = [
    Offset(796, 230), // Punto 29
    Offset(769, 187), // Punto 30
    Offset(660, 175), // Punto 31
    Offset(600, 305), // Punto 32
    Offset(698, 415), // Punto 33
    Offset(846, 357), // Punto 34
    Offset(838, 268), // Punto 35
  ];

  // Coordenadas de los puntos del Corral 6 (imagen original 1024x1024)
  static const List<Offset> _corral6Points = [
    Offset(899, 508), // Punto 36
    Offset(903, 441), // Punto 37
    Offset(857, 373), // Punto 38
    Offset(706, 431), // Punto 39
    Offset(695, 564), // Punto 40
    Offset(849, 646), // Punto 41
    Offset(902, 572), // Punto 42
  ];

  // Coordenadas de los puntos del Corral 7 (imagen original 1024x1024)
  static const List<Offset> _corral7Points = [
    Offset(773, 779), // Punto 43
    Offset(814, 746), // Punto 44
    Offset(828, 654), // Punto 45
    Offset(686, 578), // Punto 46
    Offset(580, 670), // Punto 47
    Offset(622, 830), // Punto 48
    Offset(747, 821), // Punto 49
  ];

  // Coordenadas de puntos adicionales para puertas (imagen original 1024x1024)
  static const Offset _punto50 = Offset(360, 600); // Para Puerta A1
  static const Offset _punto51 = Offset(349, 570); // Para Puerta A2
  static const Offset _punto52 = Offset(309, 463); // Para Puerta B1
  static const Offset _punto53 = Offset(324, 432); // Para Puerta B2
  static const Offset _punto54 = Offset(390, 336); // Para Puerta C1
  static const Offset _punto55 = Offset(422, 331); // Para Puerta C2
  static const Offset _punto56 = Offset(550, 310); // Para Puerta D1
  static const Offset _punto57 = Offset(577, 330); // Para Puerta D2
  static const Offset _punto58 = Offset(677, 393); // Para Puerta E1
  static const Offset _punto59 = Offset(680, 426); // Para Puerta E2
  static const Offset _punto60 = Offset(700, 534); // Para Puerta F1
  static const Offset _punto61 = Offset(668, 560); // Para Puerta F2
  static const Offset _punto62 = Offset(602, 653); // Para Puerta G1
  static const Offset _punto63 = Offset(560, 653); // Para Puerta G2

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

  // Estado de visibilidad de las puertas
  bool _showRedGates = true; // Puertas rojas (A1, B1, C1, D1, E1, F1, G1)
  bool _showGreenGates =
      false; // Puertas verdes (A2, B2, C2, D2, E2, F2, G2) - ocultas por defecto

  // Variables para almacenamiento de cantidades de bovinos por corral
  Map<String, int> _storedCorralCounts = {};
  Map<String, int> _currentCorralCounts = {};

  // Variables para control de animaciones de puertas
  final Map<String, Timer?> _gateAnimationTimers = {};
  final Map<String, bool> _animatingGates = {};

  // Mapeo de rangos de edad a corrales/puertas
  static const Map<String, String> _rangoToGate = {
    '0-6 meses': 'A',
    '7-12 meses': 'B',
    '13-24 meses': 'C',
    '25-36 meses': 'D',
    '37-48 meses': 'E',
    '49-60 meses': 'F',
    'Mayores a 60 meses': 'G',
  };

  // Getters
  bool get showCorralLines => _showCorralLines;
  bool get showCorral1Lines => _showCorral1Lines;
  bool get showCorral2Lines => _showCorral2Lines;
  bool get showCorral3Lines => _showCorral3Lines;
  bool get showCorral4Lines => _showCorral4Lines;
  bool get showCorral5Lines => _showCorral5Lines;
  bool get showCorral6Lines => _showCorral6Lines;
  bool get showCorral7Lines => _showCorral7Lines;
  bool get showRedGates => _showRedGates;
  bool get showGreenGates => _showGreenGates;
  List<Offset> get corral1Points => _corral1Points;
  List<Offset> get corral2Points => _corral2Points;
  List<Offset> get corral3Points => _corral3Points;
  List<Offset> get corral4Points => _corral4Points;
  List<Offset> get corral5Points => _corral5Points;
  List<Offset> get corral6Points => _corral6Points;
  List<Offset> get corral7Points => _corral7Points;
  double get originalImageSize => _originalImageSize;
  Map<String, int> get currentCorralCounts => _currentCorralCounts;
  Map<String, bool> get animatingGates => _animatingGates;

  /// Inicializar el provider cargando datos almacenados
  Future<void> initialize() async {
    debugPrint('=== INICIALIZANDO CATTLE PENS PROVIDER ===');
    await loadStoredCorralCounts();
    debugPrint('Datos cargados desde SharedPreferences: $_storedCorralCounts');
    notifyListeners();
  }

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

  /// Obtener las líneas de puertas escaladas según el tamaño actual
  List<GateConnection> getScaledGates(double currentSize) {
    final scaleFactor = currentSize / _originalImageSize;

    // Puntos de referencia de los corrales
    final punto5 = _corral1Points[4]; // Punto 5 del Corral 1: Offset(339, 582)
    final punto12 =
        _corral2Points[4]; // Punto 12 del Corral 2: Offset(308, 433)
    final punto19 =
        _corral3Points[4]; // Punto 19 del Corral 3: Offset(412, 311)
    final punto26 =
        _corral4Points[4]; // Punto 26 del Corral 4: Offset(578, 304)
    final punto33 =
        _corral5Points[4]; // Punto 33 del Corral 5: Offset(701, 410)
    final punto40 =
        _corral6Points[4]; // Punto 40 del Corral 6: Offset(689, 556)
    final punto47 =
        _corral7Points[4]; // Punto 47 del Corral 7: Offset(577, 666)

    final gates = [
      // Puertas del Corral 1 (A)
      GateConnection(
        start: Offset(punto5.dx * scaleFactor, punto5.dy * scaleFactor),
        end: Offset(_punto50.dx * scaleFactor, _punto50.dy * scaleFactor),
        id: 'A1',
        color: getGateColor('A1'),
      ),
      GateConnection(
        start: Offset(punto5.dx * scaleFactor, punto5.dy * scaleFactor),
        end: Offset(_punto51.dx * scaleFactor, _punto51.dy * scaleFactor),
        id: 'A2',
        color: getGateColor('A2'),
      ),

      // Puertas del Corral 2 (B)
      GateConnection(
        start: Offset(punto12.dx * scaleFactor, punto12.dy * scaleFactor),
        end: Offset(_punto52.dx * scaleFactor, _punto52.dy * scaleFactor),
        id: 'B1',
        color: getGateColor('B1'),
      ),
      GateConnection(
        start: Offset(punto12.dx * scaleFactor, punto12.dy * scaleFactor),
        end: Offset(_punto53.dx * scaleFactor, _punto53.dy * scaleFactor),
        id: 'B2',
        color: getGateColor('B2'),
      ),

      // Puertas del Corral 3 (C)
      GateConnection(
        start: Offset(punto19.dx * scaleFactor, punto19.dy * scaleFactor),
        end: Offset(_punto54.dx * scaleFactor, _punto54.dy * scaleFactor),
        id: 'C1',
        color: getGateColor('C1'),
      ),
      GateConnection(
        start: Offset(punto19.dx * scaleFactor, punto19.dy * scaleFactor),
        end: Offset(_punto55.dx * scaleFactor, _punto55.dy * scaleFactor),
        id: 'C2',
        color: getGateColor('C2'),
      ),

      // Puertas del Corral 4 (D)
      GateConnection(
        start: Offset(punto26.dx * scaleFactor, punto26.dy * scaleFactor),
        end: Offset(_punto56.dx * scaleFactor, _punto56.dy * scaleFactor),
        id: 'D1',
        color: getGateColor('D1'),
      ),
      GateConnection(
        start: Offset(punto26.dx * scaleFactor, punto26.dy * scaleFactor),
        end: Offset(_punto57.dx * scaleFactor, _punto57.dy * scaleFactor),
        id: 'D2',
        color: getGateColor('D2'),
      ),

      // Puertas del Corral 5 (E)
      GateConnection(
        start: Offset(punto33.dx * scaleFactor, punto33.dy * scaleFactor),
        end: Offset(_punto58.dx * scaleFactor, _punto58.dy * scaleFactor),
        id: 'E1',
        color: getGateColor('E1'),
      ),
      GateConnection(
        start: Offset(punto33.dx * scaleFactor, punto33.dy * scaleFactor),
        end: Offset(_punto59.dx * scaleFactor, _punto59.dy * scaleFactor),
        id: 'E2',
        color: getGateColor('E2'),
      ),

      // Puertas del Corral 6 (F)
      GateConnection(
        start: Offset(punto40.dx * scaleFactor, punto40.dy * scaleFactor),
        end: Offset(_punto60.dx * scaleFactor, _punto60.dy * scaleFactor),
        id: 'F1',
        color: getGateColor('F1'),
      ),
      GateConnection(
        start: Offset(punto40.dx * scaleFactor, punto40.dy * scaleFactor),
        end: Offset(_punto61.dx * scaleFactor, _punto61.dy * scaleFactor),
        id: 'F2',
        color: getGateColor('F2'),
      ),

      // Puertas del Corral 7 (G)
      GateConnection(
        start: Offset(punto47.dx * scaleFactor, punto47.dy * scaleFactor),
        end: Offset(_punto62.dx * scaleFactor, _punto62.dy * scaleFactor),
        id: 'G1',
        color: getGateColor('G1'),
      ),
      GateConnection(
        start: Offset(punto47.dx * scaleFactor, punto47.dy * scaleFactor),
        end: Offset(_punto63.dx * scaleFactor, _punto63.dy * scaleFactor),
        id: 'G2',
        color: getGateColor('G2'),
      ),
    ];

    // Filtrar las puertas según su visibilidad y animaciones
    return gates.where((gate) {
      // Durante animaciones, mostrar ambas puertas del par afectado
      if (isGateAnimating(gate.id)) {
        return true; // Mostrar ambas puertas durante animación
      }

      // Lógica normal de visibilidad basada en el ID de la puerta
      if (gate.id.endsWith('1') && !_showRedGates) {
        return false; // Ocultar puertas tipo 1 si están deshabilitadas
      }
      if (gate.id.endsWith('2') && !_showGreenGates) {
        return false; // Ocultar puertas tipo 2 si están deshabilitadas
      }
      return true; // Mostrar la puerta
    }).toList();
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

  /// Métodos para controlar la visibilidad de las puertas
  void toggleRedGates() {
    _showRedGates = !_showRedGates;
    notifyListeners();
  }

  void toggleGreenGates() {
    _showGreenGates = !_showGreenGates;
    notifyListeners();
  }

  void enableRedGates() {
    _showRedGates = true;
    notifyListeners();
  }

  void hideRedGates() {
    _showRedGates = false;
    notifyListeners();
  }

  void enableGreenGates() {
    _showGreenGates = true;
    notifyListeners();
  }

  void hideGreenGates() {
    _showGreenGates = false;
    notifyListeners();
  }

  /// Cargar cantidades almacenadas desde SharedPreferences
  Future<void> loadStoredCorralCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = [
        '0-6 meses',
        '7-12 meses',
        '13-24 meses',
        '25-36 meses',
        '37-48 meses',
        '49-60 meses',
        'Mayores a 60 meses',
      ];

      for (String key in keys) {
        final count = prefs.getInt('corral_$key') ?? 0;
        _storedCorralCounts[key] = count;
      }
    } catch (e) {
      debugPrint('Error loading stored corral counts: $e');
    }
  }

  /// Guardar cantidades actuales en SharedPreferences
  Future<void> saveCorralCounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (String key in _currentCorralCounts.keys) {
        await prefs.setInt('corral_$key', _currentCorralCounts[key] ?? 0);
      }
      _storedCorralCounts = Map.from(_currentCorralCounts);
    } catch (e) {
      debugPrint('Error saving corral counts: $e');
    }
  }

  /// Actualizar cantidades desde StatisticsProvider y detectar cambios
  Future<void> updateCorralCounts(Map<String, int> newCounts) async {
    _currentCorralCounts = Map.from(newCounts);

    // Detectar aumentos en cada corral
    for (String rangoEdad in newCounts.keys) {
      final currentCount = newCounts[rangoEdad] ?? 0;
      final storedCount = _storedCorralCounts[rangoEdad] ?? 0;

      // Si hay un aumento, activar animación de puertas
      if (currentCount > storedCount) {
        await _activateGateAnimation(rangoEdad);
      }
    }

    // Guardar las nuevas cantidades
    await saveCorralCounts();
    notifyListeners();
  }

  /// Activar animación de puertas para un rango de edad específico
  Future<void> _activateGateAnimation(String rangoEdad) async {
    final gatePrefix = _rangoToGate[rangoEdad];
    if (gatePrefix == null) return;

    final gateKey = '${gatePrefix}1_${gatePrefix}2';

    // Cancelar timer anterior si existe
    _gateAnimationTimers[gateKey]?.cancel();

    // Marcar puertas como animándose
    _animatingGates[gateKey] = true;
    notifyListeners();

    // Configurar timer para restaurar estado después de 10 segundos
    _gateAnimationTimers[gateKey] = Timer(const Duration(seconds: 10), () {
      _animatingGates[gateKey] = false;
      notifyListeners();
    });
  }

  /// Verificar si una puerta específica está en animación
  bool isGateAnimating(String gateName) {
    // Determinar el key basado en el nombre de la puerta
    String gateKey = '';
    if (gateName.startsWith('A')) {
      gateKey = 'A1_A2';
    } else if (gateName.startsWith('B')) {
      gateKey = 'B1_B2';
    } else if (gateName.startsWith('C')) {
      gateKey = 'C1_C2';
    } else if (gateName.startsWith('D')) {
      gateKey = 'D1_D2';
    } else if (gateName.startsWith('E')) {
      gateKey = 'E1_E2';
    } else if (gateName.startsWith('F')) {
      gateKey = 'F1_F2';
    } else if (gateName.startsWith('G')) {
      gateKey = 'G1_G2';
    }

    return _animatingGates[gateKey] ?? false;
  }

  /// Obtener color de puerta considerando animaciones
  Color getGateColor(String gateName) {
    if (isGateAnimating(gateName)) {
      // Durante animación: A1,B1,C1,D1,E1,F1,G1 -> verde, A2,B2,C2,D2,E2,F2,G2 -> rojo
      if (gateName.endsWith('1')) {
        return Colors.green; // Puerta tipo 1 se vuelve verde
      } else {
        return Colors.red; // Puerta tipo 2 se vuelve roja
      }
    } else {
      // Estado normal: A1,B1,C1,D1,E1,F1,G1 -> rojo, A2,B2,C2,D2,E2,F2,G2 -> verde
      if (gateName.endsWith('1')) {
        return Colors.red; // Puerta tipo 1 es roja por defecto
      } else {
        return Colors.green; // Puerta tipo 2 es verde por defecto
      }
    }
  }

  /// Limpiar todos los timers al dispose
  @override
  void dispose() {
    for (Timer? timer in _gateAnimationTimers.values) {
      timer?.cancel();
    }
    _gateAnimationTimers.clear();
    super.dispose();
  }

  /// Obtener las líneas originales (sin escalar) para que el widget haga el cálculo
  List<LineConnection> getOriginalLines() {
    // Retornar las líneas con coordenadas originales (basadas en imagen 1024x1024)
    return []; // Las líneas no se están usando actualmente
  }

  /// Generar puntos de ganado originales (sin escalar) para que el widget haga el cálculo
  Map<int, List<Offset>> generateOriginalCattlePoints(
    Map<String, int> rangosEdad,
  ) {
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
        // Generar puntos para este corral (coordenadas originales)
        final points = _generatePointsInPolygon(corralPoints[i], count);
        cattlePoints[corralId] = points;
      }
    }

    return cattlePoints;
  }

  /// Obtener las puertas originales (sin escalar) para que el widget haga el cálculo
  List<GateConnection> getOriginalGates() {
    // Puntos de referencia de los corrales (coordenadas originales)
    final punto5 = _corral1Points[4]; // Punto 5 del Corral 1
    final punto12 = _corral2Points[4]; // Punto 12 del Corral 2
    final punto19 = _corral3Points[4]; // Punto 19 del Corral 3
    final punto26 = _corral4Points[4]; // Punto 26 del Corral 4
    final punto33 = _corral5Points[4]; // Punto 33 del Corral 5
    final punto40 = _corral6Points[4]; // Punto 40 del Corral 6
    final punto47 = _corral7Points[4]; // Punto 47 del Corral 7

    return [
      // Puertas del Corral 1 (A) - coordenadas originales
      GateConnection(
        start: punto5,
        end: _punto50,
        id: 'A1',
        color: getGateColor('A1'),
      ),
      GateConnection(
        start: punto5,
        end: _punto51,
        id: 'A2',
        color: getGateColor('A2'),
      ),

      // Puertas del Corral 2 (B) - coordenadas originales
      GateConnection(
        start: punto12,
        end: _punto52,
        id: 'B1',
        color: getGateColor('B1'),
      ),
      GateConnection(
        start: punto12,
        end: _punto53,
        id: 'B2',
        color: getGateColor('B2'),
      ),

      // Puertas del Corral 3 (C) - coordenadas originales
      GateConnection(
        start: punto19,
        end: _punto54,
        id: 'C1',
        color: getGateColor('C1'),
      ),
      GateConnection(
        start: punto19,
        end: _punto55,
        id: 'C2',
        color: getGateColor('C2'),
      ),

      // Puertas del Corral 4 (D) - coordenadas originales
      GateConnection(
        start: punto26,
        end: _punto56,
        id: 'D1',
        color: getGateColor('D1'),
      ),
      GateConnection(
        start: punto26,
        end: _punto57,
        id: 'D2',
        color: getGateColor('D2'),
      ),

      // Puertas del Corral 5 (E) - coordenadas originales
      GateConnection(
        start: punto33,
        end: _punto58,
        id: 'E1',
        color: getGateColor('E1'),
      ),
      GateConnection(
        start: punto33,
        end: _punto59,
        id: 'E2',
        color: getGateColor('E2'),
      ),

      // Puertas del Corral 6 (F) - coordenadas originales
      GateConnection(
        start: punto40,
        end: _punto60,
        id: 'F1',
        color: getGateColor('F1'),
      ),
      GateConnection(
        start: punto40,
        end: _punto61,
        id: 'F2',
        color: getGateColor('F2'),
      ),

      // Puertas del Corral 7 (G) - coordenadas originales
      GateConnection(
        start: punto47,
        end: _punto62,
        id: 'G1',
        color: getGateColor('G1'),
      ),
      GateConnection(
        start: punto47,
        end: _punto63,
        id: 'G2',
        color: getGateColor('G2'),
      ),
    ];
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

/// Clase para representar una puerta (conexión entre dos puntos específicos)
class GateConnection {
  final Offset start;
  final Offset end;
  final String id;
  final Color color;

  const GateConnection({
    required this.start,
    required this.end,
    required this.id,
    required this.color,
  });

  @override
  String toString() {
    return 'GateConnection($id: $start -> $end)';
  }
}
