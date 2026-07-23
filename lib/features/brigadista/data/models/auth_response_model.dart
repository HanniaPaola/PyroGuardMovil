import '../../domain/entities/auth_session.dart';

/// Mapea la respuesta cruda del endpoint POST /v1/auth/login:
/// { "access_token": "string", "token_type": "string" }
class AuthResponseModel extends AuthSession {
  const AuthResponseModel({
    required super.accessToken,
    required super.tokenType,
    required super.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      role: json['rol'] as String? ?? json['usuario']?['rol'] as String? ?? '',
    );
  }
}
