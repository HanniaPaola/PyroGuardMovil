import '../data/datasources/brigadista_remote_datasource.dart';
import '../data/datasources/brigadista_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/brigadista_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../presentation/providers/brigadista_provider.dart';
import '../presentation/providers/auth_provider.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/token_storage_service.dart';
import '../../../core/network/api_client.dart';

/// Módulo de inyección de dependencias del feature Brigadista.
/// Ahora construye tanto BrigadistaProvider (datos operativos de campo)
/// como AuthProvider (sesión/login), cada uno con su propio repositorio.
class BrigadistaModule {
  static BrigadistaProvider buildProvider() {
    final remoteDataSource = BrigadistaRemoteDataSource();
    final localDataSource = BrigadistaLocalDataSource();

    final repository = BrigadistaRepositoryImpl(
      remote: remoteDataSource,
      local: localDataSource,
    );

    return BrigadistaProvider(
      repository: repository,
      connectivityService: ConnectivityService(),
      pushService: PushNotificationService(),
    );
  }

  static AuthProvider buildAuthProvider() {
    final apiClient = ApiClient();
    final tokenStorage = TokenStorageService();

    final remoteDataSource = AuthRemoteDataSource(apiClient: apiClient);

    final repository = AuthRepositoryImpl(
      remote: remoteDataSource,
      tokenStorage: tokenStorage,
    );

    return AuthProvider(repository: repository);
  }
}
