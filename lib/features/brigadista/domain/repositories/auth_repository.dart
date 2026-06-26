import '../entities/auth_session.dart';

/// Contrato de dominio para autenticación del brigadista.
abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<bool> hasActiveSession();

  Future<void> logout();
}
