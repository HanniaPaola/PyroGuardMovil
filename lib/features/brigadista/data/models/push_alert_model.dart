import '../../domain/entities/push_alert.dart';

class PushAlertModel extends PushAlert {
  const PushAlertModel({
    required super.id,
    required super.zoneId,
    required super.zoneName,
    required super.riskLevel,
    required super.distanceKm,
    required super.receivedAt,
  });

  factory PushAlertModel.fromJson(Map<String, dynamic> json) {
    return PushAlertModel(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      zoneName: json['zoneName'] as String,
      riskLevel: json['riskLevel'] as String,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      receivedAt: DateTime.parse(json['receivedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'riskLevel': riskLevel,
      'distanceKm': distanceKm,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }
}
