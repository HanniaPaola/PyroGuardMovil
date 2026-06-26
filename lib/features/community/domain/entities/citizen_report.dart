/// Reporte ciudadano de un posible incendio o foco de riesgo,
/// enviado desde la app sin necesidad de autenticación.
class CitizenReport {
  final String? id;
  final String description;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final String? status;
  final DateTime? createdAt;

  const CitizenReport({
    this.id,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    this.status,
    this.createdAt,
  });
}
