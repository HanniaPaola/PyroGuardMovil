class ZoneDto {
  final String id;
  final String name;
  final String municipality;
  final double latitude;
  final double longitude;
  final String riskLevel;
  final String mainCause;
  final String recommendation;
  final String lastUpdated;

  ZoneDto({
    required this.id,
    required this.name,
    required this.municipality,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.mainCause,
    required this.recommendation,
    required this.lastUpdated,
  });

  factory ZoneDto.fromJson(Map<String, dynamic> json) => ZoneDto(
    id: json['id'],
    name: json['name'],
    municipality: json['municipality'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    riskLevel: json['risk_level'],
    mainCause: json['main_cause'],
    recommendation: json['recommendation'],
    lastUpdated: json['last_updated'],
  );
}
