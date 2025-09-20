import 'dart:typed_data';

/// Modelo para representar un keypoint de pose
class Keypoint {
  final double x;
  final double y;
  final double confidence;

  const Keypoint({required this.x, required this.y, required this.confidence});

  factory Keypoint.fromJson(List<dynamic> json) {
    return Keypoint(
      x: json[0].toDouble(),
      y: json[1].toDouble(),
      confidence: json[2].toDouble(),
    );
  }

  List<double> toJson() {
    return [x, y, confidence];
  }
}

/// Modelo para representar una detección de pose
class PoseDetection {
  final String className;
  final List<Keypoint> keypoints;

  const PoseDetection({required this.className, required this.keypoints});

  factory PoseDetection.fromJson(Map<String, dynamic> json) {
    return PoseDetection(
      className: json['class'],
      keypoints: (json['keypoints'] as List)
          .map((keypoint) => Keypoint.fromJson(keypoint))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': className,
      'keypoints': keypoints.map((k) => k.toJson()).toList(),
    };
  }
}

/// Modelo para la respuesta de predicción de pose
class PosePredictionResponse {
  final List<PoseDetection> detections;

  const PosePredictionResponse({required this.detections});

  factory PosePredictionResponse.fromJson(Map<String, dynamic> json) {
    return PosePredictionResponse(
      detections: (json['detections'] as List)
          .map((detection) => PoseDetection.fromJson(detection))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'detections': detections.map((d) => d.toJson()).toList()};
  }
}

/// DTO para enviar imagen a la API
class PoseAnalysisRequest {
  final String image;

  const PoseAnalysisRequest({required this.image});

  Map<String, dynamic> toJson() {
    return {'image': image};
  }
}

/// Modelo para resultado de análisis con imagen procesada
class PoseAnalysisResult {
  final String? imagePath; // Para móvil con File
  final String imageIdentifier; // Identificador único para web o móvil
  final PosePredictionResponse prediction;
  final String imageType; // 'lateral' o 'posterior'
  final Uint8List
  resizedImageBytes; // La imagen reducida al 25% para mostrar en UI

  const PoseAnalysisResult({
    this.imagePath, // Opcional para web
    required this.imageIdentifier,
    required this.prediction,
    required this.imageType,
    required this.resizedImageBytes,
  });
}
