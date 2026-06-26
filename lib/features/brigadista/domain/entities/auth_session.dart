/// Sesión autenticada del brigadista. Entidad de dominio pura, sin
/// conocimiento de cómo se obtuvo (HTTP, caché, etc.).
class AuthSession {
  final String accessToken;
  final String tokenType;

  const AuthSession({required this.accessToken, required this.tokenType});

  /// Header listo para usar en futuras peticiones autenticadas.
  String get authorizationHeader => '$tokenType $accessToken';
}
