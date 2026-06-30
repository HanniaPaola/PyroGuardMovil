/// Constantes de configuración de la API central de PyroGuard.
/// Cualquier feature que consuma el backend referencia estas constantes
/// en lugar de hardcodear URLs.
class ApiConstants {
  static const String baseUrl = 'https://pyroguard.inode.cloud/api';

  // Auth (brigadista)
  static const String login = '/v1/auth/login';

  // Ciudadano (community) — endpoints públicos, sin autenticación
  static const String citizenReports = '/v1/ciudadano/reportes';

  // Subida de archivos
  static const String uploadFile = '/v1/archivos/upload';

  // Comunicados de la comunidad
  static const String comunicados = '/v1/comunicados/activos';
}
