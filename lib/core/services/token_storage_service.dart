import 'package:shared_preferences/shared_preferences.dart';

/// Persistencia del token de sesión del brigadista. Usa SharedPreferences
/// por consistencia con el resto del proyecto (mismo mecanismo que usa
/// BrigadistaLocalDataSource para el caché offline).
///
/// Nota: para producción, considera migrar a flutter_secure_storage,
/// ya que SharedPreferences no encripta los datos en disco.
class TokenStorageService {
  static const _tokenKey = 'brigadista_access_token';
  static const _tokenTypeKey = 'brigadista_token_type';

  Future<void> saveToken({
    required String accessToken,
    required String tokenType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_tokenTypeKey, tokenType);
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getTokenType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenTypeKey);
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_tokenTypeKey);
  }
}
