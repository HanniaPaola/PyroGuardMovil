import 'package:flutter/material.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/alert_history.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/usecases/get_nearby_zones_usecase.dart';
import '../../domain/usecases/get_alert_history_usecase.dart';
import '../../domain/usecases/get_weather_conditions_usecase.dart';
import '../../domain/usecases/get_citizen_reports_usecase.dart'; // Which now contains GetComunicadosUsecase
import '../../domain/entities/comunicado.dart';

class CommunityProvider extends ChangeNotifier {
  final GetNearbyZonesUsecase getNearbyZones;
  final GetAlertHistoryUsecase getAlertHistory;
  final GetWeatherConditionsUsecase getWeatherConditions;
  final GetComunicadosUsecase getComunicados;

  CommunityProvider({
    required this.getNearbyZones,
    required this.getAlertHistory,
    required this.getWeatherConditions,
    required this.getComunicados,
  });

  List<Zone> zones = [];
  List<AlertHistory> alertHistory = [];
  List<Comunicado> comunicados = [];
  WeatherCondition? weather;
  Zone? selectedZone;
  bool loadingZones = false;
  bool loadingHistory = false;
  bool loadingComunicados = false;
  bool loadingWeather = false;
  String? error;

  Future<void> loadZones() async {
    loadingZones = true;
    error = null;
    notifyListeners();
    try {
      zones = await getNearbyZones(16.75, -93.11);
    } catch (e) {
      error = 'No se pudieron cargar las zonas.';
    } finally {
      loadingZones = false;
      notifyListeners();
    }
  }

  Future<void> loadAlertHistory(String zoneId) async {
    loadingHistory = true;
    notifyListeners();
    try {
      alertHistory = await getAlertHistory(zoneId);
    } catch (e) {
      error = 'No se pudo cargar el historial.';
    } finally {
      loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadComunicados() async {
    loadingComunicados = true;
    notifyListeners();
    try {
      comunicados = await getComunicados();
    } catch (e) {
      error = 'No se pudieron cargar los comunicados.';
    } finally {
      loadingComunicados = false;
      notifyListeners();
    }
  }

  Future<void> loadWeather(String zoneId) async {
    loadingWeather = true;
    notifyListeners();
    try {
      weather = await getWeatherConditions(zoneId);
    } catch (e) {
      error = 'No se pudo cargar el clima.';
    } finally {
      loadingWeather = false;
      notifyListeners();
    }
  }

  void selectZone(Zone zone) {
    selectedZone = zone;
    notifyListeners();
    loadAlertHistory(zone.id);
    loadWeather(zone.id);
  }
}
