class AlertHistory {
  final String id;
  final String zoneName;
  final String riskLevel;
  final DateTime startDate;
  final DateTime? endDate;
  final bool derivedToBrigade;

  const AlertHistory({
    required this.id,
    required this.zoneName,
    required this.riskLevel,
    required this.startDate,
    this.endDate,
    required this.derivedToBrigade,
  });

  Duration? get duration =>
      endDate?.difference(startDate);
}
