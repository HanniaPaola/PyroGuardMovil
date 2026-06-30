import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/comunicado_model.dart';

class ComunicadoRemoteDataSource {
  final ApiClient apiClient;

  ComunicadoRemoteDataSource({required this.apiClient});

  Future<List<ComunicadoModel>> getComunicados() async {
    final response = await apiClient.getJsonList(ApiConstants.comunicados);
    return response.map((e) => ComunicadoModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
