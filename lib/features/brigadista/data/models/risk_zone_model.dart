import '../../domain/entities/risk_zone.dart';

class RiskZoneModel extends RiskZone {
  const RiskZoneModel({
    required super.id,
    required super.name,
    required super.municipality,
    required super.latitude,
    required super.longitude,
    required super.riskLevel,
    required super.mainCause,
    required super.technicalDirective,
    required super.lastUpdated,
  });

  factory RiskZoneModel.fromJson(Map<String, dynamic> json) {
    return RiskZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      municipality: json['municipality'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      mainCause: json['mainCause'] as String,
      technicalDirective: json['technicalDirective'] as String? ?? '',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'municipality': municipality,
      'latitude': latitude,
      'longitude': longitude,
      'riskLevel': riskLevel,
      'mainCause': mainCause,
      'technicalDirective': technicalDirective,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory RiskZoneModel.fromEntity(RiskZone zone) {
    return RiskZoneModel(
      id: zone.id,
      name: zone.name,
      municipality: zone.municipality,
      latitude: zone.latitude,
      longitude: zone.longitude,
      riskLevel: zone.riskLevel,
      mainCause: zone.mainCause,
      technicalDirective: zone.technicalDirective,
      lastUpdated: zone.lastUpdated,
    );
  }
}
