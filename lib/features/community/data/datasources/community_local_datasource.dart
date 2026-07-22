import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/alert_history.dart';
import '../../domain/entities/weather_condition.dart';
import '../datasources/remote/model/zone_dto.dart';
import '../datasources/remote/model/alert_history_dto.dart';
import '../datasources/remote/model/weather_dto.dart';
import '../datasources/remote/mapper/community_mapper.dart';
import '../models/comunicado_model.dart';
import '../models/citizen_report_model.dart';

class CommunityLocalDataSource {
  static const _zonesKey = 'community_cached_zones';
  static const _alertsKeyPrefix = 'community_cached_alerts_';
  static const _weatherKeyPrefix = 'community_cached_weather_';
  static const _comunicadosKey = 'community_cached_comunicados';
  static const _pendingReportsKey = 'community_pending_reports';

  // --- Zonas ---
  Future<void> cacheZones(List<ZoneDto> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = zones
        .map(
          (z) => {
            'id_zona': z.id,
            'nombre': z.name,
            'municipio': z.municipality,
            'latitud': z.latitude,
            'longitud': z.longitude,
            'nivel_riesgo': z.riskLevel,
            'causa_principal': z.mainCause,
            'recomendacion': z.recommendation,
            'ultima_actualizacion': z.lastUpdated,
          },
        )
        .toList();
    await prefs.setString(_zonesKey, jsonEncode(jsonList));
  }

  Future<List<Zone>> getCachedZones() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_zonesKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) {
      return CommunityMapper.zoneFromDto(
        ZoneDto(
          id: e['id_zona'] ?? '',
          name: e['nombre'] ?? '',
          municipality: e['municipio'] ?? '',
          latitude: (e['latitud'] as num?)?.toDouble() ?? 0.0,
          longitude: (e['longitud'] as num?)?.toDouble() ?? 0.0,
          riskLevel: e['nivel_riesgo'] ?? 'bajo',
          mainCause: e['causa_principal'] ?? '',
          recommendation: e['recomendacion'] ?? '',
          lastUpdated: e['ultima_actualizacion'] ?? '',
        ),
      );
    }).toList();
  }

  // --- Historial de Alertas ---
  Future<void> cacheAlertHistory(
    String zoneId,
    List<AlertHistoryDto> alerts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = alerts
        .map(
          (a) => {
            'id': a.id,
            'nombre_zona': a.zoneName,
            'nivel_riesgo': a.riskLevel,
            'fecha_inicio': a.startDate,
            'fecha_fin': a.endDate,
            'derivado_brigada': a.derivedToBrigade,
          },
        )
        .toList();
    await prefs.setString('$_alertsKeyPrefix$zoneId', jsonEncode(jsonList));
  }

  Future<List<AlertHistory>> getCachedAlertHistory(String zoneId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_alertsKeyPrefix$zoneId');
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded.map((e) {
      return CommunityMapper.alertFromDto(
        AlertHistoryDto(
          id: e['id'] ?? '',
          zoneName: e['nombre_zona'] ?? '',
          riskLevel: e['nivel_riesgo'] ?? 'bajo',
          startDate: e['fecha_inicio'] ?? '',
          endDate: e['fecha_fin'],
          derivedToBrigade: e['derivado_brigada'] ?? false,
        ),
      );
    }).toList();
  }

  // --- Clima ---
  Future<void> cacheWeather(String zoneId, WeatherDto weather) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'id_zona': weather.zoneId,
      'temperatura': weather.temperature,
      'humedad': weather.humidity,
      'viento': weather.windSpeed,
      'dias_sin_lluvia': weather.daysWithoutRain,
      'explicacion': weather.explanation,
      'actualizado_en': weather.updatedAt,
    };
    await prefs.setString('$_weatherKeyPrefix$zoneId', jsonEncode(data));
  }

  Future<WeatherCondition?> getCachedWeather(String zoneId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_weatherKeyPrefix$zoneId');
    if (raw == null) return null;
    final Map<String, dynamic> e = jsonDecode(raw);
    return CommunityMapper.weatherFromDto(
      WeatherDto(
        zoneId: e['id_zona'] ?? '',
        temperature: (e['temperatura'] as num?)?.toDouble() ?? 0.0,
        humidity: (e['humedad'] as num?)?.toDouble() ?? 0.0,
        windSpeed: (e['viento'] as num?)?.toDouble() ?? 0.0,
        daysWithoutRain: e['dias_sin_lluvia'] ?? 0,
        explanation: e['explicacion'] ?? '',
        updatedAt: e['actualizado_en'] ?? '',
      ),
    );
  }

  // --- Comunicados ---
  Future<void> cacheComunicados(List<ComunicadoModel> comunicados) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = comunicados.map((c) => c.toJson()).toList();
    await prefs.setString(_comunicadosKey, jsonEncode(jsonList));
  }

  Future<List<ComunicadoModel>> getCachedComunicados() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_comunicadosKey);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw);
    return decoded
        .map((e) => ComunicadoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Reportes Pendientes ---
  Future<void> queueReport(CitizenReportModel report) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingReportsKey);
    final List<dynamic> list = raw != null ? jsonDecode(raw) : [];
    list.add(report.toRequestJson());
    await prefs.setString(_pendingReportsKey, jsonEncode(list));
  }

  Future<List<Map<String, dynamic>>> getQueuedReports() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingReportsKey);
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(raw));
  }

  Future<void> clearQueuedReports() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingReportsKey);
  }
}
