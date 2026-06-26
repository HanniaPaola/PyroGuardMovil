import '../data/repositories/community_repository_impl.dart';
import '../domain/usecases/get_nearby_zones_usecase.dart';
import '../domain/usecases/get_alert_history_usecase.dart';
import '../domain/usecases/get_weather_conditions_usecase.dart';
import '../domain/usecases/submit_citizen_report_usecase.dart';
import '../data/datasources/citizen_report_remote_datasource.dart';
import '../data/repositories/citizen_report_repository_impl.dart';
import '../presentation/providers/community_provider.dart';
import '../presentation/providers/citizen_report_provider.dart';
import '../../../core/network/api_client.dart';

class CommunityModule {
  static CommunityProvider buildProvider() {
    final repo = CommunityRepositoryImpl();
    return CommunityProvider(
      getNearbyZones: GetNearbyZonesUsecase(repo),
      getAlertHistory: GetAlertHistoryUsecase(repo),
      getWeatherConditions: GetWeatherConditionsUsecase(repo),
    );
  }

  /// Reportes ciudadanos: endpoint público (sin autenticación) para
  /// POST /v1/ciudadano/reportes.
  static CitizenReportProvider buildCitizenReportProvider() {
    final apiClient = ApiClient();

    final remoteDataSource = CitizenReportRemoteDataSource(
      apiClient: apiClient,
    );

    final repository = CitizenReportRepositoryImpl(remote: remoteDataSource);

    return CitizenReportProvider(
      submitReport: SubmitCitizenReportUsecase(repository),
    );
  }
}
