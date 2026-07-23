class InputSanitizer {
  /// Limpieza de Entradas (Input Cleaning) - Trim
  /// Elimina espacios en blanco al inicio y al final.
  static String cleanString(String input) {
    return input.trim();
  }

  /// Escapado de Caracteres (HTML Context)
  /// Convierte caracteres especiales como <, >, & en entidades HTML.
  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Filtrado de Entradas (Blacklisting básico)
  /// Bloquea caracteres comunes en inyección SQL o scripts.
  static String filterDangerousChars(String input) {
    // Ejemplo: remover etiquetas script o intentos de inyección
    final regex = RegExp(
      r'(<script.*?>.*?</script>)|(DELETE FROM|DROP TABLE|INSERT INTO|UPDATE)',
      caseSensitive: false,
    );
    return input.replaceAll(regex, '');
  }

  /// Sanitización integral para campos de texto descriptivos
  static String sanitizeDescription(String input) {
    String cleaned = cleanString(input);
    cleaned = filterDangerousChars(cleaned);
    cleaned = escapeHtml(cleaned);
    return cleaned;
  }
}
