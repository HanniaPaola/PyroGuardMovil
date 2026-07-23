import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zone_intervention_model.dart';
import '../models/risk_zone_model.dart';
import '../../domain/entities/simple_zone.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_constants.dart';
import '../models/active_intervention_model.dart';

/// Fuente remota simulada. Reemplazar las implementaciones con llamadas
/// reales (Dio/http) al backend central cuando esté disponible.
class BrigadistaRemoteDataSource {
  final ApiClient apiClient;

  BrigadistaRemoteDataSource({required this.apiClient});

  Future<List<SimpleZone>> fetchSimpleZones() async {
    try {
      final response = await http.get(
        Uri.parse('https://pyroguard.inode.cloud/ml/api/v1/zonas/simple'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map(
              (z) => SimpleZone(
                id: z['id_zona'] as String? ?? '',
                name: z['nombre'] as String? ?? 'Desconocida',
              ),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<RiskZoneModel>> fetchRiskZones() async {
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

        return geoData.map((item) {
          final id = item['id_zona'] as String? ?? '';
          final nombre = item['nombre'] as String? ?? 'Zona desconocida';
          final riesgo = riskMap[nombre] ?? 'bajo';

          return RiskZoneModel(
            id: id,
            name: nombre,
            municipality: 'Chiapas',
            latitude: 16.0,
            longitude: -93.0,
            riskLevel: riesgo,
            mainCause: 'Monitoreo automatizado con ML.',
            technicalDirective:
                'Siga las directivas correspondientes al nivel de riesgo detectado.',
            lastUpdated: DateTime.now(),
          );
        }).toList();
      }
    } catch (e) {
      // Ignorar y usar fallback
    }

    await Future.delayed(const Duration(milliseconds: 600));

    return [
      RiskZoneModel(
        id: 'z-001',
        name: 'Reserva El Ocote - Sector Norte',
        municipality: 'Ocozocoautla, Chiapas',
        latitude: 16.789,
        longitude: -93.654,
        riskLevel: 'crítico',
        mainCause: 'Sequía prolongada y viento sostenido > 25 km/h.',
        technicalDirective:
            'Activar protocolo Conafor nivel 3: establecer línea de control '
            'a 50m del frente de avance, notificar a brigadas vecinas y '
            'suspender quemas agrícolas en un radio de 5 km.',
        lastUpdated: DateTime.now(),
      ),
      RiskZoneModel(
        id: 'z-002',
        name: 'Cañón del Sumidero - Ladera Este',
        municipality: 'Tuxtla Gutiérrez, Chiapas',
        latitude: 16.857,
        longitude: -93.087,
        riskLevel: 'alto',
        mainCause: 'Vegetación seca acumulada, sin lluvia en 18 días.',
        technicalDirective:
            'Realizar rondas de vigilancia cada 4 horas. Mantener equipo de '
            'control de incendios pre-posicionado conforme a NOM-015-SEMARNAT.',
        lastUpdated: DateTime.now(),
      ),
    ];
  }

  Future<List<ZoneInterventionModel>> fetchInterventions(String zoneId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final rnd = Random();
    final results = ['Controlado', 'Extinguido', 'Contenido', 'En seguimiento'];
    final brigades = [
      'Brigada Norte',
      'Brigada Conafor-12',
      'Brigada Municipal',
    ];

    return List.generate(5, (i) {
      return ZoneInterventionModel(
        id: '$zoneId-int-$i',
        zoneId: zoneId,
        date: DateTime.now().subtract(Duration(days: 20 * (i + 1))),
        brigadeName: brigades[rnd.nextInt(brigades.length)],
        result: results[rnd.nextInt(results.length)],
        riskLevelAtTime: ['bajo', 'medio', 'alto', 'crítico'][rnd.nextInt(4)],
      );
    });
  }

  Future<void> uploadObservation(Map<String, dynamic> jsonObs) async {
    final payload = {
      "id_zona": jsonObs['zoneId'],
      "latitud": jsonObs['latitude'],
      "longitud": jsonObs['longitude'],
      "condiciones": (jsonObs['selectedOptions'] as List).join(', '),
      "recursos_necesarios": "N/A",
      "observaciones_texto": jsonObs['conditionNotes'],
    };

    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    // ApiClient already appends 'Bearer ' when passing bearerToken

    try {
      await apiClient.postJson(
        '/v1/observaciones/',
        payload,
        bearerToken: token,
      );
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> sendEmergency(double latitude, double longitude) async {
    // Por el momento no hay endpoint, simulamos el envío de emergencia con un retardo.
    await Future.delayed(const Duration(seconds: 2));
    /*
    final payload = {
      "latitud": latitude,
      "longitud": longitude,
      "tipo": "SOS_BRIGADISTA",
      "timestamp": DateTime.now().toIso8601String(),
    };
    final token = await TokenStorageService().getAccessToken();
    await apiClient.postJson('/v1/emergencias/', payload, bearerToken: token);
    */
  }

  Future<List<ActiveInterventionModel>> fetchActiveInterventions() async {
    final token = await TokenStorageService().getAccessToken();
    final response = await apiClient.getJsonList(
      ApiConstants.activeInterventions,
      bearerToken: token,
    );
    return response.map((e) => ActiveInterventionModel.fromJson(e)).toList();
  }

  Future<void> closeIntervention(
    String idIntervencion,
    String estado,
    String observaciones,
  ) async {
    final token = await TokenStorageService().getAccessToken();
    final payload = {"estado": estado, "observaciones": observaciones};
    await apiClient.putJson(
      '${ApiConstants.closeIntervention}$idIntervencion',
      payload,
      bearerToken: token,
    );
  }
}
