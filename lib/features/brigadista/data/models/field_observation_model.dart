import '../../domain/entities/field_observation.dart';

class FieldObservationModel extends FieldObservation {
  const FieldObservationModel({
    required super.id,
    required super.zoneId,
    required super.latitude,
    required super.longitude,
    required super.conditionNotes,
    required super.selectedOptions,
    required super.createdAt,
    super.synced = false,
  });

  factory FieldObservationModel.fromJson(Map<String, dynamic> json) {
    return FieldObservationModel(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      conditionNotes: json['conditionNotes'] as String,
      selectedOptions: List<String>.from(json['selectedOptions'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'latitude': latitude,
      'longitude': longitude,
      'conditionNotes': conditionNotes,
      'selectedOptions': selectedOptions,
      'createdAt': createdAt.toIso8601String(),
      'synced': synced,
    };
  }

  factory FieldObservationModel.fromEntity(FieldObservation o) {
    return FieldObservationModel(
      id: o.id,
      zoneId: o.zoneId,
      latitude: o.latitude,
      longitude: o.longitude,
      conditionNotes: o.conditionNotes,
      selectedOptions: o.selectedOptions,
      createdAt: o.createdAt,
      synced: o.synced,
    );
  }
}
