/// Entidad de dominio que representa una zona de riesgo forestal
/// monitoreada por el sistema (HU01, HU02, HU04, HU07).
class RiskZone {
  final String id;
  final String name;
  final String municipality;
  final double latitude;
  final double longitude;

  /// Valores esperados: 'bajo', 'medio', 'alto', 'crítico'
  final String riskLevel;
  final String mainCause;

  /// Directiva técnica generada por NLP en base a normativas Conafor (HU04)
  final String technicalDirective;
  final DateTime lastUpdated;

  const RiskZone({
    required this.id,
    required this.name,
    required this.municipality,
    required this.latitude,
    required this.longitude,
    required this.riskLevel,
    required this.mainCause,
    required this.technicalDirective,
    required this.lastUpdated,
  });

  RiskZone copyWith({
    String? riskLevel,
    String? technicalDirective,
    DateTime? lastUpdated,
  }) {
    return RiskZone(
      id: id,
      name: name,
      municipality: municipality,
      latitude: latitude,
      longitude: longitude,
      riskLevel: riskLevel ?? this.riskLevel,
      mainCause: mainCause,
      technicalDirective: technicalDirective ?? this.technicalDirective,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
