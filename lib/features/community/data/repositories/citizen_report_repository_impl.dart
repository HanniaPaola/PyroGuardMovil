import '../../domain/entities/citizen_report.dart';
import '../../domain/repositories/citizen_report_repository.dart';
import '../datasources/citizen_report_remote_datasource.dart';
import '../datasources/community_local_datasource.dart';
import '../models/citizen_report_model.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CitizenReportRepositoryImpl implements CitizenReportRepository {
  final CitizenReportRemoteDataSource remote;
  final CommunityLocalDataSource localDataSource;

  CitizenReportRepositoryImpl({
    required this.remote,
    required this.localDataSource,
  });

  Future<bool> get _isOnline async =>
      await InternetConnection().hasInternetAccess;

  @override
  Future<CitizenReport> submitReport({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    if (await _isOnline) {
      try {
        return await remote.submitReport(
          description: description,
          latitude: latitude,
          longitude: longitude,
          photoUrl: photoUrl,
        );
      } catch (_) {
        // Fallback a encolar localmente
      }
    }

    // Guardar offline
    final offlineReport = CitizenReportModel(
      id: 'offline_${DateTime.now().millisecondsSinceEpoch}',
      description: description,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
      status: 'pendiente_sincronizacion',
      createdAt: DateTime.now(),
    );
    await localDataSource.queueReport(offlineReport);
    return offlineReport;
  }

  @override
  Future<void> syncPendingReports() async {
    if (!await _isOnline) return;

    final pending = await localDataSource.getQueuedReports();
    if (pending.isEmpty) return;

    for (final obs in pending) {
      try {
        await remote.submitReport(
          description: obs['descripcion'] ?? '',
          latitude: (obs['latitud'] as num).toDouble(),
          longitude: (obs['longitud'] as num).toDouble(),
          photoUrl: obs['foto_url'],
        );
      } catch (_) {
        continue;
      }
    }
    await localDataSource.clearQueuedReports();
  }
}
