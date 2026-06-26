class Zone {
  final String id;
  final String name;
  final String municipality;
  final double latitude;
  final double longitude;
  final String riskLevel;
  final String mainCause;
  final String recommendation;
  final DateTime lastUpdated;

  const Zone({
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
}
