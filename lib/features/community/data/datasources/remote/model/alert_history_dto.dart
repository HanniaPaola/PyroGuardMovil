class AlertHistoryDto {
  final String id;
  final String zoneName;
  final String riskLevel;
  final String startDate;
  final String? endDate;
  final bool derivedToBrigade;

  AlertHistoryDto({
    required this.id,
    required this.zoneName,
    required this.riskLevel,
    required this.startDate,
    this.endDate,
    required this.derivedToBrigade,
  });

  factory AlertHistoryDto.fromJson(Map<String, dynamic> json) =>
      AlertHistoryDto(
        id: json['id'],
        zoneName: json['zone_name'],
        riskLevel: json['risk_level'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        derivedToBrigade: json['derived_to_brigade'] ?? false,
      );
}
