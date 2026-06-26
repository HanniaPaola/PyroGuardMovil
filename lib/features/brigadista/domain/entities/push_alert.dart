/// Alerta push geolocalizada recibida por el brigadista (HU02, HU06).
class PushAlert {
  final String id;
  final String zoneId;
  final String zoneName;
  final String riskLevel;
  final double distanceKm;
  final DateTime receivedAt;

  const PushAlert({
    required this.id,
    required this.zoneId,
    required this.zoneName,
    required this.riskLevel,
    required this.distanceKm,
    required this.receivedAt,
  });
}
