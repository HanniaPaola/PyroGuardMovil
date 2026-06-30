import '../entities/comunicado.dart';

abstract class ComunicadoRepository {
  Future<List<Comunicado>> getComunicados();
}
