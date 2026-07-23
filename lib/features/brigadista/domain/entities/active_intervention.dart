class ActiveIntervention {
  final String idIntervencion;
  final String idBrigada;
  final String idZona;
  final String estado;
  final String? observaciones;
  final DateTime fechaAsignacion;
  final DateTime? fechaCompletada;

  const ActiveIntervention({
    required this.idIntervencion,
    required this.idBrigada,
    required this.idZona,
    required this.estado,
    this.observaciones,
    required this.fechaAsignacion,
    this.fechaCompletada,
  });
}
