/// Modelo de datos del usuario (DTO)
class UserModel {
  final String id;
  final String email;
  final String? createdAt;
  final PerfilModel? perfil;

  UserModel({
    required this.id,
    required this.email,
    this.createdAt,
    this.perfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'],
      perfil: json['perfil'] != null
          ? PerfilModel.fromJson(json['perfil'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'created_at': createdAt,
      'perfil': perfil?.toJson(),
    };
  }
}

/// Modelo de perfil del usuario
class PerfilModel {
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String? direccion;
  final String? fechaNacimiento;

  PerfilModel({
    this.nombre,
    this.apellido,
    this.telefono,
    this.direccion,
    this.fechaNacimiento,
  });

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    return PerfilModel(
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaNacimiento: json['fecha_nacimiento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'direccion': direccion,
      'fecha_nacimiento': fechaNacimiento,
    };
  }
}

/// Modelo para la respuesta de tokens
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserModel user;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      expiresIn: json['expires_in'] ?? 0,
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}

/// DTO para registro de usuario
class UserRegisterDto {
  final String email;
  final String password;
  final String? nombreCompleto;

  UserRegisterDto({
    required this.email,
    required this.password,
    this.nombreCompleto,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'nombre_completo': nombreCompleto,
    };
  }
}

/// DTO para login de usuario
class UserLoginDto {
  final String email;
  final String password;

  UserLoginDto({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
