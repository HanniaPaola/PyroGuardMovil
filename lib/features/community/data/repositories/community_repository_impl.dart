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
import '../datasources/community_local_datasource.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityLocalDataSource localDataSource;

  CommunityRepositoryImpl({required this.localDataSource});

  Future<bool> get _isOnline async =>
      await InternetConnection().hasInternetAccess;

  @override
  Future<List<Zone>> getNearbyZones(double lat, double lng) async {
    if (await _isOnline) {
      try {
        final responses = await Future.wait([
          http.get(Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/')),
          http.get(
            Uri.parse(
              'https://pyroguard.inode.cloud/ml/api/v1/zonas/riesgo-publico',
            ),
          ),
        ]);

        if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
          final List<dynamic> geoData = json.decode(responses[0].body);
          final List<dynamic> riskData = json.decode(responses[1].body);

          final Map<String, String> riskMap = {};
          for (var item in riskData) {
            riskMap[item['nombre'] as String] = item['nivel_riesgo'] as String;
          }

          final dtoList = geoData.map((item) {
            final id = item['id_zona'] as String? ?? '';
            final nombre = item['nombre'] as String? ?? 'Zona desconocida';
            final riesgo = riskMap[nombre] ?? 'bajo';

            return ZoneDto(
              id: id,
              name: nombre,
              municipality: 'Chiapas',
              latitude: 16.0,
              longitude: -93.0,
              riskLevel: riesgo,
              mainCause: 'Condiciones detectadas por ML',
              recommendation: 'Mantente alerta y sigue las recomendaciones.',
              lastUpdated: DateTime.now().toIso8601String(),
            );
          }).toList();

          await localDataSource.cacheZones(dtoList);
          return dtoList.map(CommunityMapper.zoneFromDto).toList();
        }
      } catch (e) {
        // Fallback a caché
      }
    }

    // Offline o error: devolver caché
    final cached = await localDataSource.getCachedZones();
    if (cached.isNotEmpty) return cached;

    // Fallback de mocks si no hay caché
    return _getMockZones().map(CommunityMapper.zoneFromDto).toList();
  }

  List<ZoneDto> _getMockZones() {
    return [
      ZoneDto(
        id: '1',
        name: 'Reserva El Ocote',
        municipality: 'Cintalapa',
        latitude: 16.90,
        longitude: -93.75,
        riskLevel: 'alto',
        mainCause: 'Calor extremo y viento fuerte',
        recommendation: 'Evita encender fogatas.',
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
  }

  @override
  Future<List<Zone>> getAllZones() => getNearbyZones(0, 0);

  @override
  Future<List<AlertHistory>> getAlertHistory(
    String zoneId, {
    int months = 6,
  }) async {
    if (await _isOnline) {
      // Simular llamada a red
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
      ];
      await localDataSource.cacheAlertHistory(zoneId, mocks);
      return mocks.map(CommunityMapper.alertFromDto).toList();
    }

    final cached = await localDataSource.getCachedAlertHistory(zoneId);
    return cached;
  }

  @override
  Future<WeatherCondition> getWeatherCondition(String zoneId) async {
    if (await _isOnline) {
      await Future.delayed(const Duration(milliseconds: 500));
      final dto = WeatherDto(
        zoneId: zoneId,
        temperature: 38.4,
        humidity: 22.0,
        windSpeed: 45.0,
        daysWithoutRain: 18,
        explanation: 'Lleva 18 días sin llover...',
        updatedAt: DateTime.now().toIso8601String(),
      );
      await localDataSource.cacheWeather(zoneId, dto);
      return CommunityMapper.weatherFromDto(dto);
    }

    final cached = await localDataSource.getCachedWeather(zoneId);
    if (cached != null) return cached;
    throw Exception('Modo offline: sin datos del clima');
  }
}
