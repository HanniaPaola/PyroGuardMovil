/// Excepción de red genérica para toda la app. Encapsula el código de
/// estado HTTP y un mensaje legible para mostrar en UI.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;

  /// Traduce errores comunes de autenticación a mensajes claros para
  /// el brigadista, sin exponer detalles técnicos del backend.
  factory ApiException.fromStatusCode(int statusCode, String? rawBody) {
    switch (statusCode) {
      case 400:
      case 401:
        return ApiException(
          'Correo o contraseña incorrectos.',
          statusCode: statusCode,
        );
      case 422:
        return ApiException(
          'Revisa que el correo y la contraseña tengan el formato correcto.',
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
        return ApiException(
          'El servidor no está disponible. Intenta más tarde.',
          statusCode: statusCode,
        );
      default:
        return ApiException(
          'Ocurrió un error inesperado. Intenta de nuevo.',
          statusCode: statusCode,
        );
    }
  }
}
