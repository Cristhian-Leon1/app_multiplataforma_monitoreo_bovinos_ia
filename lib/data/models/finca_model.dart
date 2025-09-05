/// Modelo de datos para Finca
class FincaModel {
  final String id;
  final String nombre;
  final String propietarioId;
  final String createdAt;
  final List<Map<String, dynamic>>?
  bovinos; // Lista de bovinos como dict según el backend

  FincaModel({
    required this.id,
    required this.nombre,
    required this.propietarioId,
    required this.createdAt,
    this.bovinos,
  });

  factory FincaModel.fromJson(Map<String, dynamic> json) {
    return FincaModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      propietarioId: json['propietario_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      bovinos: json['bovinos'] != null
          ? List<Map<String, dynamic>>.from(json['bovinos'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'propietario_id': propietarioId,
      'created_at': createdAt,
      'bovinos': bovinos,
    };
  }
}

/// DTO para crear una nueva finca (solo requiere el nombre)
class FincaCreateDto {
  final String nombre;

  FincaCreateDto({required this.nombre});

  Map<String, dynamic> toJson() {
    return {'nombre': nombre};
  }
}

/// DTO para actualizar una finca (solo el nombre es modificable)
class FincaUpdateDto {
  final String nombre;

  FincaUpdateDto({required this.nombre});

  Map<String, dynamic> toJson() {
    return {'nombre': nombre};
  }
}
