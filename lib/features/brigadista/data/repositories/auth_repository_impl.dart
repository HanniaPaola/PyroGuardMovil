import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/token_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorageService tokenStorage;

  AuthRepositoryImpl({required this.remote, required this.tokenStorage});

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await remote.login(email: email, password: password);

    if (session.role.toLowerCase() != 'brigadista') {
      throw ApiException('Acceso denegado. Se requiere cuenta de brigadista.');
    }

    await tokenStorage.saveToken(
      accessToken: session.accessToken,
      tokenType: session.tokenType,
    );

    return session;
  }

  @override
  Future<bool> hasActiveSession() async {
    return tokenStorage.hasValidSession();
  }

  @override
  Future<void> logout() async {
    await tokenStorage.clearSession();
  }
}
