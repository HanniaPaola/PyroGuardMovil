import '../entities/citizen_report.dart';

/// Contrato de dominio para el envío de reportes ciudadanos.
abstract class CitizenReportRepository {
  /// Envía un nuevo reporte y retorna el reporte creado (con id, estado
  /// y fecha asignados por el backend).
  Future<CitizenReport> submitReport({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  });

  /// Sincroniza los reportes pendientes almacenados localmente.
  Future<void> syncPendingReports();
}
