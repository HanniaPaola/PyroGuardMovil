import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/auth_response_model.dart';

/// Fuente remota de autenticación. Habla directamente con
/// POST /v1/auth/login usando application/x-www-form-urlencoded,
/// tal como lo exige OAuth2PasswordRequestForm en el backend FastAPI.
class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    String loginUrl = dotenv.env['URL_LOGIN'] ?? ApiConstants.login;
    if (!loginUrl.endsWith('/login')) {
      if (loginUrl.endsWith('/')) {
        loginUrl += 'login';
      } else {
        loginUrl += '/login';
      }
    }
    final response = await apiClient.postJson(loginUrl, {
      'email': email,
      'password': password,
    });

    return AuthResponseModel.fromJson(response);
  }
}
