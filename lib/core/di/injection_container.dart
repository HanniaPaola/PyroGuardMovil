import 'package:get_it/get_it.dart';

import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/usecases/get_nearby_zones_usecase.dart';
import '../../features/community/domain/usecases/get_alert_history_usecase.dart';
import '../../features/community/domain/usecases/get_weather_conditions_usecase.dart';
import '../../features/community/domain/usecases/submit_citizen_report_usecase.dart';
import '../../features/community/domain/usecases/get_citizen_reports_usecase.dart';
import '../../features/community/data/datasources/citizen_report_remote_datasource.dart';
import '../../features/community/data/datasources/comunicado_remote_datasource.dart';
import '../../features/community/data/datasources/community_local_datasource.dart';
import '../../features/community/data/repositories/comunicado_repository_impl.dart';
import '../../features/community/domain/repositories/comunicado_repository.dart';
import '../../features/community/data/repositories/citizen_report_repository_impl.dart';
import '../../features/community/domain/repositories/citizen_report_repository.dart';
import '../../features/community/presentation/providers/community_provider.dart';
import '../../features/community/presentation/providers/citizen_report_provider.dart';

import '../../features/brigadista/data/datasources/brigadista_remote_datasource.dart';
import '../../features/brigadista/data/datasources/brigadista_local_datasource.dart';
import '../../features/brigadista/data/datasources/auth_remote_datasource.dart';
import '../../features/brigadista/data/repositories/brigadista_repository_impl.dart';
import '../../features/brigadista/domain/repositories/brigadista_repository.dart';
import '../../features/brigadista/data/repositories/auth_repository_impl.dart';
import '../../features/brigadista/domain/repositories/auth_repository.dart';
import '../../features/brigadista/presentation/providers/brigadista_provider.dart';
import '../../features/brigadista/presentation/providers/auth_provider.dart';

import '../services/connectivity_service.dart';
import '../services/push_notification_service.dart';
import '../services/token_storage_service.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

void init() {
  // Core / Services
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => PushNotificationService());
  sl.registerLazySingleton(() => TokenStorageService());

  // Data sources
  sl.registerLazySingleton(() => ComunicadoRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(
    () => CitizenReportRemoteDataSource(apiClient: sl()),
  );
  sl.registerLazySingleton(() => CommunityLocalDataSource());
  sl.registerLazySingleton(() => BrigadistaRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton(() => BrigadistaLocalDataSource());
  sl.registerLazySingleton(() => AuthRemoteDataSource(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ComunicadoRepository>(
    () => ComunicadoRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<CitizenReportRepository>(
    () => CitizenReportRepositoryImpl(remote: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<BrigadistaRepository>(
    () => BrigadistaRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), tokenStorage: sl()),
  );

  // Usecases
  sl.registerLazySingleton(() => GetNearbyZonesUsecase(sl()));
  sl.registerLazySingleton(() => GetAlertHistoryUsecase(sl()));
  sl.registerLazySingleton(() => GetWeatherConditionsUsecase(sl()));
  sl.registerLazySingleton(() => GetComunicadosUsecase(sl()));
  sl.registerLazySingleton(() => SubmitCitizenReportUsecase(sl()));

  // Providers
  sl.registerFactory(
    () => CommunityProvider(
      getNearbyZones: sl(),
      getAlertHistory: sl(),
      getWeatherConditions: sl(),
      getComunicados: sl(),
    ),
  );
  sl.registerFactory(
    () => CitizenReportProvider(
      submitReport: sl(),
      connectivityService: sl(),
      repository: sl(),
    ),
  );
  sl.registerFactory(
    () => BrigadistaProvider(
      repository: sl(),
      connectivityService: sl(),
      pushService: sl(),
    ),
  );
  sl.registerFactory(() => AuthProvider(repository: sl()));
}
