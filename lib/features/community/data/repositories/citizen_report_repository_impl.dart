import '../../domain/entities/citizen_report.dart';
import '../../domain/repositories/citizen_report_repository.dart';
import '../datasources/citizen_report_remote_datasource.dart';

class CitizenReportRepositoryImpl implements CitizenReportRepository {
  final CitizenReportRemoteDataSource remote;

  CitizenReportRepositoryImpl({required this.remote});

  @override
  Future<CitizenReport> submitReport({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    return remote.submitReport(
      description: description,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
    );
  }
}
