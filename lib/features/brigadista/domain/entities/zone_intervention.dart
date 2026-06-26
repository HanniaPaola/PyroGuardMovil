/// Registro histórico de una intervención previa en una zona (HU07).
class ZoneIntervention {
  final String id;
  final String zoneId;
  final DateTime date;
  final String brigadeName;
  final String result;
  final String riskLevelAtTime;

  const ZoneIntervention({
    required this.id,
    required this.zoneId,
    required this.date,
    required this.brigadeName,
    required this.result,
    required this.riskLevelAtTime,
  });
}
