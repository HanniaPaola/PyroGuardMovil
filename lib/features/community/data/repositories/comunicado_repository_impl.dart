import '../../domain/entities/comunicado.dart';
import '../../domain/repositories/comunicado_repository.dart';
import '../datasources/comunicado_remote_datasource.dart';

class ComunicadoRepositoryImpl implements ComunicadoRepository {
  final ComunicadoRemoteDataSource remote;

  ComunicadoRepositoryImpl({required this.remote});

  @override
  Future<List<Comunicado>> getComunicados() {
    return remote.getComunicados();
  }
}
