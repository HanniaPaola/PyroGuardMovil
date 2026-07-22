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
    final loginUrl = dotenv.env['URL_LOGIN'] ?? ApiConstants.login;
    final response = await apiClient.postForm(loginUrl, {
      // El backend espera 'username', aunque conceptualmente sea el correo.
      'username': email,
      'password': password,
    });

    return AuthResponseModel.fromJson(response);
  }
}
