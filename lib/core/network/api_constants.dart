import 'env.dart';

/// Constantes de configuración de la API central de PyroGuard.
/// Cualquier feature que consuma el backend referencia estas constantes
/// en lugar de hardcodear URLs.
class ApiConstants {
  static final String baseUrl = Env.baseUrl;

  // Auth (brigadista)
  static const String login = '/v1/auth/login';

  // Reportes ciudadanos (público)
  static const String citizenReports = '/v1/reportes';

  // FCM Token
  static const String registerToken = '/v1/notificaciones/token';
  static const String deleteToken = '/v1/notificaciones/token';

  // Intervenciones
  static const String activeInterventions =
      '/v1/intervenciones/mis-tareas/activas';
  static const String closeIntervention = '/v1/intervenciones/'; // Append ID

  // Subida de archivos
  static const String uploadFile = '/v1/archivos/upload';

  // Comunicados de la comunidad
  static const String comunicados = '/v1/comunicados';
}
