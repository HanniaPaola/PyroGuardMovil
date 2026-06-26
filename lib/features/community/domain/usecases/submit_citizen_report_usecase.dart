import '../entities/citizen_report.dart';
import '../repositories/citizen_report_repository.dart';

/// Caso de uso: enviar un reporte ciudadano. Sigue el mismo patrón que
/// GetNearbyZonesUsecase, GetAlertHistoryUsecase, etc. — una clase
/// dedicada por acción, que el Provider invoca sin conocer el repositorio.
class SubmitCitizenReportUsecase {
  final CitizenReportRepository repository;

  SubmitCitizenReportUsecase(this.repository);

  Future<CitizenReport> call({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) {
    return repository.submitReport(
      description: description,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
    );
  }
}
