import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/token_storage_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

/// Estado de autenticación del brigadista. Independiente de
/// BrigadistaProvider para no mezclar responsabilidades: este provider
/// solo sabe de login/logout/sesión.
class AuthProvider extends ChangeNotifier {
  final AuthRepository repository;
  final PushNotificationService pushNotificationService;
  final TokenStorageService tokenStorage;

  AuthProvider({
    required this.repository,
    required this.pushNotificationService,
    required this.tokenStorage,
  });

  Future<void> checkSession() async {
    final hasSession = await repository.hasActiveSession();
    if (hasSession) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        await pushNotificationService.registerToken(token);
      }
    }
  }

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
      final session = await repository.login(email: email, password: password);
      await pushNotificationService.registerToken(session.accessToken);
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
    await pushNotificationService.deleteToken();
    await repository.logout();
    _status = AuthStatus.idle;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
