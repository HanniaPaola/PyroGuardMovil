import 'package:flutter/material.dart';
import '../../domain/entities/zone.dart';
import '../../domain/entities/alert_history.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/usecases/get_nearby_zones_usecase.dart';
import '../../domain/usecases/get_alert_history_usecase.dart';
import '../../domain/usecases/get_weather_conditions_usecase.dart';

class CommunityProvider extends ChangeNotifier {
  final GetNearbyZonesUsecase _getNearbyZones;
  final GetAlertHistoryUsecase _getAlertHistory;
  final GetWeatherConditionsUsecase _getWeatherConditions;

  CommunityProvider({
    required GetNearbyZonesUsecase getNearbyZones,
    required GetAlertHistoryUsecase getAlertHistory,
    required GetWeatherConditionsUsecase getWeatherConditions,
  }) : _getNearbyZones = getNearbyZones,
       _getAlertHistory = getAlertHistory,
       _getWeatherConditions = getWeatherConditions;

  List<Zone> zones = [];
  List<AlertHistory> alertHistory = [];
  WeatherCondition? weather;
  Zone? selectedZone;
  bool loadingZones = false;
  bool loadingHistory = false;
  bool loadingWeather = false;
  String? error;

  Future<void> loadZones() async {
    loadingZones = true;
    error = null;
    notifyListeners();
    try {
      zones = await _getNearbyZones(16.75, -93.11);
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
      alertHistory = await _getAlertHistory(zoneId);
    } catch (e) {
      error = 'No se pudo cargar el historial.';
    } finally {
      loadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> loadWeather(String zoneId) async {
    loadingWeather = true;
    notifyListeners();
    try {
      weather = await _getWeatherConditions(zoneId);
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
