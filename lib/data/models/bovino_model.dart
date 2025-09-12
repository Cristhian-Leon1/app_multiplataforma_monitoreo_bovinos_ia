/// Modelo base del bovino
class BovinoBase {
  final String idBovino;
  final String? sexo;
  final String? raza;

  BovinoBase({required this.idBovino, this.sexo, this.raza});

  Map<String, dynamic> toJson() {
    return {'id_bovino': idBovino, 'sexo': sexo, 'raza': raza};
  }
}

/// DTO para crear un nuevo bovino
class BovinoCreateDto extends BovinoBase {
  final String fincaId;

  BovinoCreateDto({
    required super.idBovino,
    required this.fincaId,
    super.sexo,
    super.raza,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id_bovino': idBovino,
      'finca_id': fincaId,
      'sexo': sexo,
      'raza': raza,
    };
  }
}

/// DTO para actualizar un bovino
class BovinoUpdateDto {
  final String? idBovino;
  final String? sexo;
  final String? raza;

  BovinoUpdateDto({this.idBovino, this.sexo, this.raza});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (idBovino != null) data['id_bovino'] = idBovino;
    if (sexo != null) data['sexo'] = sexo;
    if (raza != null) data['raza'] = raza;
    return data;
  }
}

/// Modelo de respuesta del bovino
class BovinoModel extends BovinoBase {
  final String id;
  final String fincaId;
  final String createdAt;

  BovinoModel({
    required this.id,
    required super.idBovino,
    required this.fincaId,
    required this.createdAt,
    super.sexo,
    super.raza,
  });

  factory BovinoModel.fromJson(Map<String, dynamic> json) {
    return BovinoModel(
      id: json['id']?.toString() ?? '',
      idBovino: json['id_bovino']?.toString() ?? '',
      fincaId: json['finca_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      sexo: json['sexo']?.toString(),
      raza: json['raza']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_bovino': idBovino,
      'finca_id': fincaId,
      'created_at': createdAt,
      'sexo': sexo,
      'raza': raza,
    };
  }
}

/// Modelo del bovino con mediciones
class BovinoWithMedicionesModel extends BovinoModel {
  final List<Map<String, dynamic>> mediciones;

  BovinoWithMedicionesModel({
    required super.id,
    required super.idBovino,
    required super.fincaId,
    required super.createdAt,
    super.sexo,
    super.raza,
    required this.mediciones,
  });

  factory BovinoWithMedicionesModel.fromJson(Map<String, dynamic> json) {
    return BovinoWithMedicionesModel(
      id: json['id']?.toString() ?? '',
      idBovino: json['id_bovino']?.toString() ?? '',
      fincaId: json['finca_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      sexo: json['sexo']?.toString(),
      raza: json['raza']?.toString(),
      mediciones: json['mediciones'] != null
          ? List<Map<String, dynamic>>.from(json['mediciones'])
          : [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['mediciones'] = mediciones;
    return json;
  }
}
