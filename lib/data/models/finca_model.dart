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

/// Modelo para bovino con su última medición
class BovinoWithLastMedicion {
  final String id;
  final String idBovino;
  final String? sexo;
  final String? raza;
  final String fincaId;
  final String createdAt;
  final Map<String, dynamic>? ultimaMedicion;

  BovinoWithLastMedicion({
    required this.id,
    required this.idBovino,
    this.sexo,
    this.raza,
    required this.fincaId,
    required this.createdAt,
    this.ultimaMedicion,
  });

  factory BovinoWithLastMedicion.fromJson(Map<String, dynamic> json) {
    return BovinoWithLastMedicion(
      id: json['id']?.toString() ?? '',
      idBovino: json['id_bovino']?.toString() ?? '',
      sexo: json['sexo']?.toString(),
      raza: json['raza']?.toString(),
      fincaId: json['finca_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      ultimaMedicion: json['ultima_medicion'] != null
          ? Map<String, dynamic>.from(json['ultima_medicion'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_bovino': idBovino,
      'sexo': sexo,
      'raza': raza,
      'finca_id': fincaId,
      'created_at': createdAt,
      'ultima_medicion': ultimaMedicion,
    };
  }
}

/// Modelo para finca completa con bovinos y sus mediciones
class FincaWithBovinosAndMediciones {
  final String id;
  final String nombre;
  final String propietarioId;
  final String createdAt;
  final List<BovinoWithLastMedicion> bovinos;
  final int totalBovinos;
  final int bovinosConMedicionesRecientes;

  FincaWithBovinosAndMediciones({
    required this.id,
    required this.nombre,
    required this.propietarioId,
    required this.createdAt,
    required this.bovinos,
    required this.totalBovinos,
    required this.bovinosConMedicionesRecientes,
  });

  factory FincaWithBovinosAndMediciones.fromJson(Map<String, dynamic> json) {
    return FincaWithBovinosAndMediciones(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      propietarioId: json['propietario_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      bovinos: json['bovinos'] != null
          ? (json['bovinos'] as List)
                .map((bovino) => BovinoWithLastMedicion.fromJson(bovino))
                .toList()
          : [],
      totalBovinos: json['total_bovinos']?.toInt() ?? 0,
      bovinosConMedicionesRecientes:
          json['bovinos_con_mediciones_recientes']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'propietario_id': propietarioId,
      'created_at': createdAt,
      'bovinos': bovinos.map((bovino) => bovino.toJson()).toList(),
      'total_bovinos': totalBovinos,
      'bovinos_con_mediciones_recientes': bovinosConMedicionesRecientes,
    };
  }
}
