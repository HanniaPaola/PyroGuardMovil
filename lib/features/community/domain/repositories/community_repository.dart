import '../entities/zone.dart';
import '../entities/alert_history.dart';
import '../entities/weather_condition.dart';

abstract class CommunityRepository {
  Future<List<Zone>> getNearbyZones(double lat, double lng);
  Future<List<Zone>> getAllZones();
  Future<List<AlertHistory>> getAlertHistory(String zoneId, {int months = 6});
  Future<WeatherCondition> getWeatherCondition(String zoneId);
}
