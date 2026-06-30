import '../entities/comunicado.dart';
import '../repositories/comunicado_repository.dart';

class GetComunicadosUsecase {
  final ComunicadoRepository repository;

  GetComunicadosUsecase(this.repository);

  Future<List<Comunicado>> call() {
    return repository.getComunicados();
  }
}
