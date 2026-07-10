import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistencia del token de sesión del brigadista.
/// Utiliza flutter_secure_storage para encriptar los datos localmente,
/// reforzando la seguridad de la aplicación (mejores prácticas).
class TokenStorageService {
  static const _tokenKey = 'brigadista_access_token';
  static const _tokenTypeKey = 'brigadista_token_type';

  final _storage = const FlutterSecureStorage();

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _tokenTypeKey, value: tokenType);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _tokenTypeKey);
  }
}
