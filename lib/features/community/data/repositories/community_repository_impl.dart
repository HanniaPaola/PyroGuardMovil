import '../../domain/entities/zone.dart';
import '../../domain/entities/alert_history.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/remote/mapper/community_mapper.dart';
import '../datasources/remote/model/zone_dto.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../datasources/remote/model/alert_history_dto.dart';
import '../datasources/remote/model/weather_dto.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  // Por ahora retorna datos mock para desarrollo.
  // Reemplazar con llamadas HTTP reales a FastAPI.

  @override
  Future<List<Zone>> getNearbyZones(double lat, double lng) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/')),
        http.get(Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/riesgo-publico')),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final List<dynamic> geoData = json.decode(responses[0].body);
        final List<dynamic> riskData = json.decode(responses[1].body);

        final Map<String, String> riskMap = {};
        for (var item in riskData) {
          riskMap[item['nombre'] as String] = item['nivel_riesgo'] as String;
        }

        return geoData.map((item) {
          final id = item['id_zona'] as String? ?? '';
          final nombre = item['nombre'] as String? ?? 'Zona desconocida';
          final riesgo = riskMap[nombre] ?? 'bajo';
          
          return CommunityMapper.zoneFromDto(ZoneDto(
            id: id,
            name: nombre,
            municipality: 'Chiapas',
            latitude: 16.0,
            longitude: -93.0,
            riskLevel: riesgo,
            mainCause: 'Condiciones detectadas por ML',
            recommendation: 'Mantente alerta y sigue las recomendaciones.',
            lastUpdated: DateTime.now().toIso8601String(),
          ));
        }).toList();
      }
    } catch (e) {
      // Ignorar error y usar fallback de mocks
    }

    await Future.delayed(const Duration(milliseconds: 800));
    final mocks = [
      ZoneDto(
        id: '1',
        name: 'Reserva El Ocote',
        municipality: 'Cintalapa',
        latitude: 16.90,
        longitude: -93.75,
        riskLevel: 'alto',
        mainCause: 'Calor extremo y viento fuerte',
        recommendation: 'Evita encender fogatas. Mantente alerta.',
        lastUpdated: DateTime.now().toIso8601String(),
      ),
      ZoneDto(
        id: '2',
        name: 'Sierra Madre Sur',
        municipality: 'Villaflores',
        latitude: 16.22,
        longitude: -93.27,
        riskLevel: 'crítico',
        mainCause: 'Sequía prolongada',
        recommendation: 'No quemes. Llama al 911 si ves humo.',
        lastUpdated: DateTime.now().toIso8601String(),
      ),
    ];
    return mocks.map(CommunityMapper.zoneFromDto).toList();
  }

  @override
  Future<List<Zone>> getAllZones() => getNearbyZones(0, 0);

  @override
  Future<List<AlertHistory>> getAlertHistory(
    String zoneId, {
    int months = 6,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final mocks = [
      AlertHistoryDto(
        id: 'a1',
        zoneName: 'Reserva El Ocote',
        riskLevel: 'crítico',
        startDate: now.subtract(const Duration(days: 5)).toIso8601String(),
        endDate: now.subtract(const Duration(days: 4)).toIso8601String(),
        derivedToBrigade: true,
      ),
      AlertHistoryDto(
        id: 'a2',
        zoneName: 'Reserva El Ocote',
        riskLevel: 'alto',
        startDate: now.subtract(const Duration(days: 20)).toIso8601String(),
        endDate: now.subtract(const Duration(days: 19)).toIso8601String(),
        derivedToBrigade: false,
      ),
      AlertHistoryDto(
        id: 'a3',
        zoneName: 'Reserva El Ocote',
        riskLevel: 'medio',
        startDate: now.subtract(const Duration(days: 45)).toIso8601String(),
        endDate: now.subtract(const Duration(days: 44)).toIso8601String(),
        derivedToBrigade: false,
      ),
    ];
    return mocks.map(CommunityMapper.alertFromDto).toList();
  }

  @override
  Future<WeatherCondition> getWeatherCondition(String zoneId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return CommunityMapper.weatherFromDto(
      WeatherDto(
        zoneId: zoneId,
        temperature: 38.4,
        humidity: 22.0,
        windSpeed: 45.0,
        daysWithoutRain: 18,
        explanation:
            'Lleva 18 días sin llover, la temperatura supera los 38°C y el viento está fuerte. Estas condiciones aumentan significativamente el peligro de incendio.',
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );
  }
}
