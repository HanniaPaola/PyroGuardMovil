import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/citizen_report_model.dart';

/// Fuente remota de reportes ciudadanos. Endpoint público, sin token.
class CitizenReportRemoteDataSource {
  final ApiClient apiClient;

  CitizenReportRemoteDataSource({required this.apiClient});

  Future<CitizenReportModel> submitReport({
    required String description,
    required double latitude,
    required double longitude,
    String? photoUrl,
  }) async {
    final draft = CitizenReportModel(
      description: description,
      latitude: latitude,
      longitude: longitude,
      photoUrl: photoUrl,
    );

    final response = await apiClient.postJson(
      ApiConstants.citizenReports,
      draft.toRequestJson(),
    );

    return CitizenReportModel.fromJson(response);
  }
}
