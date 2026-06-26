import '../../domain/entities/zone_intervention.dart';

class ZoneInterventionModel extends ZoneIntervention {
  const ZoneInterventionModel({
    required super.id,
    required super.zoneId,
    required super.date,
    required super.brigadeName,
    required super.result,
    required super.riskLevelAtTime,
  });

  factory ZoneInterventionModel.fromJson(Map<String, dynamic> json) {
    return ZoneInterventionModel(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      date: DateTime.parse(json['date'] as String),
      brigadeName: json['brigadeName'] as String,
      result: json['result'] as String,
      riskLevelAtTime: json['riskLevelAtTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'date': date.toIso8601String(),
      'brigadeName': brigadeName,
      'result': result,
      'riskLevelAtTime': riskLevelAtTime,
    };
  }
}
