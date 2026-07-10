import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_constants.dart';
import 'api_exception.dart';

dynamic _decodeJson(String source) => jsonDecode(source);

/// Cliente HTTP delgado y reutilizable. Centraliza la construcción de
/// requests para que los datasources de cualquier feature no dupliquen
/// lógica de bajo nivel (headers, manejo de errores, baseUrl, etc.).
class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  Uri _buildUri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  /// POST con body application/x-www-form-urlencoded.
  /// Usado por endpoints tipo OAuth2PasswordRequestForm (ej. login).
  Future<Map<String, dynamic>> postForm(
    String path,
    Map<String, String> formFields,
  ) async {
    try {
      final response = await _httpClient.post(
        _buildUri(path),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: formFields,
      );

      return await _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }
  }

  /// POST con body application/json. Disponible para otros endpoints
  /// del feature que sí esperen JSON.
  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? bearerToken,
  }) async {
    try {
      final response = await _httpClient.post(
        _buildUri(path),
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(body),
      );

      return await _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }
  }

  /// GET que retorna una lista de JSON (Array).
  Future<List<dynamic>> getJsonList(
    String path, {
    String? bearerToken,
  }) async {
    try {
      final response = await _httpClient.get(
        _buildUri(path),
        headers: {
          'Content-Type': 'application/json',
          if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
        },
      );

      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      if (!isSuccess) {
        throw ApiException.fromStatusCode(response.statusCode, response.body);
      }

      if (response.body.isEmpty) return [];

      final decoded = await compute(_decodeJson, response.body);
      if (decoded is List) return decoded;

      throw ApiException('Respuesta inesperada del servidor.');
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }
  }

  /// POST para subir archivos (multipart/form-data).
  Future<Map<String, dynamic>> postMultipart(
    String path,
    String fileField,
    String filePath, {
    String? bearerToken,
  }) async {
    try {
      final request = http.MultipartRequest('POST', _buildUri(path));
      if (bearerToken != null) {
        request.headers['Authorization'] = 'Bearer $bearerToken';
      }
      
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamedResponse = await _httpClient.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return await _handleResponse(response);
    } on http.ClientException {
      throw ApiException(
        'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    }
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (!isSuccess) {
      throw ApiException.fromStatusCode(response.statusCode, response.body);
    }

    if (response.body.isEmpty) return {};

    final decoded = await compute(_decodeJson, response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw ApiException('Respuesta inesperada del servidor.');
  }

  void dispose() => _httpClient.close();
}
