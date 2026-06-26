import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_exception.dart';

enum AuthStatus { idle, loading, authenticated, error }

/// Estado de autenticación del brigadista. Independiente de
/// BrigadistaProvider para no mezclar responsabilidades: este provider
/// solo sabe de login/logout/sesión.
class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;

  AuthProvider({required this.repository});

  AuthStatus _status = AuthStatus.idle;
  AuthStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == AuthStatus.loading;

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.login(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'Ocurrió un error inesperado. Intenta de nuevo.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repository.logout();
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
