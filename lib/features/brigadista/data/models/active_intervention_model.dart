import '../../domain/entities/active_intervention.dart';

class ActiveInterventionModel extends ActiveIntervention {
  ActiveInterventionModel({
    required super.idIntervencion,
    required super.idBrigada,
    required super.idZona,
    required super.estado,
    super.observaciones,
    required super.fechaAsignacion,
    super.fechaCompletada,
  });

  factory ActiveInterventionModel.fromJson(Map<String, dynamic> json) {
    return ActiveInterventionModel(
      idIntervencion: json['id_intervencion'] as String? ?? '',
      idBrigada: json['id_brigada'] as String? ?? '',
      idZona: json['id_zona'] as String? ?? '',
      estado: json['estado'] as String? ?? '',
      observaciones: json['observaciones'] as String?,
      fechaAsignacion: DateTime.parse(json['fecha_asignacion']),
      fechaCompletada: json['fecha_completada'] != null
          ? DateTime.parse(json['fecha_completada'])
          : null,
    );
  }
}
