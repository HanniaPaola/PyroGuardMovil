import '../../domain/entities/citizen_report.dart';

/// Mapea el body y la respuesta de POST /v1/ciudadano/reportes:
///
/// Request:
/// { "descripcion": "...", "latitud": -90, "longitud": -180, "foto_url": "..." }
///
/// Response:
/// {
///   "id_reporte": "uuid",
///   "descripcion": "...",
///   "latitud": 0,
///   "longitud": 0,
///   "foto_url": "...",
///   "estado": "...",
///   "creado_en": "2026-06-26T14:50:51.062Z"
/// }
class CitizenReportModel extends CitizenReport {
  const CitizenReportModel({
    super.id,
    required super.description,
    required super.latitude,
    required super.longitude,
    super.photoUrl,
    super.status,
    super.createdAt,
  });

  /// Construye el body a enviar al backend (claves en español, según API).
  Map<String, dynamic> toRequestJson() {
    return {
      'descripcion': description,
      'latitud': latitude,
      'longitud': longitude,
      if (photoUrl != null && photoUrl!.isNotEmpty) 'foto_url': photoUrl,
    };
  }

  factory CitizenReportModel.fromJson(Map<String, dynamic> json) {
    return CitizenReportModel(
      id: json['id_reporte'] as String?,
      description: json['descripcion'] as String? ?? '',
      latitude: (json['latitud'] as num).toDouble(),
      longitude: (json['longitud'] as num).toDouble(),
      photoUrl: json['foto_url'] as String?,
      status: json['estado'] as String?,
      createdAt: json['creado_en'] != null
          ? DateTime.parse(json['creado_en'] as String)
          : null,
    );
  }
}
