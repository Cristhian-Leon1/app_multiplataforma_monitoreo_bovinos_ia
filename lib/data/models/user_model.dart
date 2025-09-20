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
    // DEBUG - JSON del usuario: $json
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
    // DEBUG - JSON del perfil: $json
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

/// DTO para subir imagen de perfil en base64
class ProfileImageUploadRequest {
  final String imageBase64;
  final String? fileName;
  final String userId; // UUID del usuario

  ProfileImageUploadRequest({
    required this.imageBase64,
    required this.userId,
    this.fileName,
  });

  Map<String, dynamic> toJson() {
    return {
      'image_base64': imageBase64,
      'file_name': fileName,
      'user_id': userId,
    };
  }
}

/// Respuesta de subida de imagen de perfil
class ProfileImageUploadResponse {
  final String url;
  final String publicUrl;
  final String fileName;
  final bool profileUpdated;

  ProfileImageUploadResponse({
    required this.url,
    required this.publicUrl,
    required this.fileName,
    required this.profileUpdated,
  });

  factory ProfileImageUploadResponse.fromJson(Map<String, dynamic> json) {
    return ProfileImageUploadResponse(
      url: json['url'] ?? '',
      publicUrl: json['public_url'] ?? '',
      fileName: json['file_name'] ?? '',
      profileUpdated: json['profile_updated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'public_url': publicUrl,
      'file_name': fileName,
      'profile_updated': profileUpdated,
    };
  }
}
