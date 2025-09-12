import 'dart:core';

/// Modelo base de medición
class MedicionBase {
  final DateTime fecha;
  final double? alturaCm;
  final double? lTorsoCm;
  final double? lOblicuaCm;
  final double? lCaderaCm;
  final double? aCaderaCm;
  final int? edadMeses;
  final double? pesoBasculaKg;

  MedicionBase({
    required this.fecha,
    this.alturaCm,
    this.lTorsoCm,
    this.lOblicuaCm,
    this.lCaderaCm,
    this.aCaderaCm,
    this.edadMeses,
    this.pesoBasculaKg,
  });

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String().split(
        'T',
      )[0], // Solo la fecha (YYYY-MM-DD)
      'altura_cm': alturaCm,
      'l_torso_cm': lTorsoCm,
      'l_oblicua_cm': lOblicuaCm,
      'l_cadera_cm': lCaderaCm,
      'a_cadera_cm': aCaderaCm,
      'edad_meses': edadMeses,
      'peso_bascula_kg': pesoBasculaKg,
    };
  }
}

/// DTO para crear una nueva medición
class MedicionCreateDto extends MedicionBase {
  final String bovinoId;

  MedicionCreateDto({
    required this.bovinoId,
    required super.fecha,
    super.alturaCm,
    super.lTorsoCm,
    super.lOblicuaCm,
    super.lCaderaCm,
    super.aCaderaCm,
    super.edadMeses,
    super.pesoBasculaKg,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['bovino_id'] = bovinoId;
    return json;
  }
}

/// DTO para actualizar una medición
class MedicionUpdateDto {
  final DateTime? fecha;
  final double? alturaCm;
  final double? lTorsoCm;
  final double? lOblicuaCm;
  final double? lCaderaCm;
  final double? aCaderaCm;
  final int? edadMeses;
  final double? pesoBasculaKg;

  MedicionUpdateDto({
    this.fecha,
    this.alturaCm,
    this.lTorsoCm,
    this.lOblicuaCm,
    this.lCaderaCm,
    this.aCaderaCm,
    this.edadMeses,
    this.pesoBasculaKg,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (fecha != null) data['fecha'] = fecha!.toIso8601String().split('T')[0];
    if (alturaCm != null) data['altura_cm'] = alturaCm;
    if (lTorsoCm != null) data['l_torso_cm'] = lTorsoCm;
    if (lOblicuaCm != null) data['l_oblicua_cm'] = lOblicuaCm;
    if (lCaderaCm != null) data['l_cadera_cm'] = lCaderaCm;
    if (aCaderaCm != null) data['a_cadera_cm'] = aCaderaCm;
    if (edadMeses != null) data['edad_meses'] = edadMeses;
    if (pesoBasculaKg != null) data['peso_bascula_kg'] = pesoBasculaKg;
    return data;
  }
}

/// Modelo de respuesta de medición
class MedicionModel extends MedicionBase {
  final String id;
  final String bovinoId;
  final DateTime createdAt;

  MedicionModel({
    required this.id,
    required this.bovinoId,
    required this.createdAt,
    required super.fecha,
    super.alturaCm,
    super.lTorsoCm,
    super.lOblicuaCm,
    super.lCaderaCm,
    super.aCaderaCm,
    super.edadMeses,
    super.pesoBasculaKg,
  });

  factory MedicionModel.fromJson(Map<String, dynamic> json) {
    return MedicionModel(
      id: json['id']?.toString() ?? '',
      bovinoId: json['bovino_id']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      fecha:
          DateTime.tryParse(json['fecha']?.toString() ?? '') ?? DateTime.now(),
      alturaCm: json['altura_cm'] != null
          ? double.tryParse(json['altura_cm'].toString())
          : null,
      lTorsoCm: json['l_torso_cm'] != null
          ? double.tryParse(json['l_torso_cm'].toString())
          : null,
      lOblicuaCm: json['l_oblicua_cm'] != null
          ? double.tryParse(json['l_oblicua_cm'].toString())
          : null,
      lCaderaCm: json['l_cadera_cm'] != null
          ? double.tryParse(json['l_cadera_cm'].toString())
          : null,
      aCaderaCm: json['a_cadera_cm'] != null
          ? double.tryParse(json['a_cadera_cm'].toString())
          : null,
      edadMeses: json['edad_meses'] != null
          ? int.tryParse(json['edad_meses'].toString())
          : null,
      pesoBasculaKg: json['peso_bascula_kg'] != null
          ? double.tryParse(json['peso_bascula_kg'].toString())
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['id'] = id;
    json['bovino_id'] = bovinoId;
    json['created_at'] = createdAt.toIso8601String();
    return json;
  }
}
