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
    print('DEBUG - JSON del usuario: $json');
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
  final String? nombreCompleto;
  final String? imagenPerfil;

  PerfilModel({this.nombreCompleto, this.imagenPerfil});

  factory PerfilModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG - JSON del perfil: $json');
    return PerfilModel(
      nombreCompleto: json['nombre_completo'],
      imagenPerfil: json['imagen_perfil'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'nombre_completo': nombreCompleto, 'imagen_perfil': imagenPerfil};
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
