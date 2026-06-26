/// Observación técnica capturada en campo por el brigadista (HU03).
/// Se persiste localmente cuando no hay conexión y se sincroniza después.
class FieldObservation {
  final String id;
  final String zoneId;
  final double latitude;
  final double longitude;
  final String conditionNotes;

  /// Opciones predefinidas seleccionadas: ej. ['acceso_vehicular', 'agua_cercana']
  final List<String> selectedOptions;
  final DateTime createdAt;

  /// true si ya fue enviada al backend, false si está pendiente de sync
  final bool synced;

  const FieldObservation({
    required this.id,
    required this.zoneId,
    required this.latitude,
    required this.longitude,
    required this.conditionNotes,
    required this.selectedOptions,
    required this.createdAt,
    this.synced = false,
  });

  FieldObservation copyWith({bool? synced}) {
    return FieldObservation(
      id: id,
      zoneId: zoneId,
      latitude: latitude,
      longitude: longitude,
      conditionNotes: conditionNotes,
      selectedOptions: selectedOptions,
      createdAt: createdAt,
      synced: synced ?? this.synced,
    );
  }
}
