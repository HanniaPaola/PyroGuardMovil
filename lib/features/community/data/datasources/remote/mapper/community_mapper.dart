import '../../../../domain/entities/zone.dart';
import '../../../../domain/entities/alert_history.dart';
import '../../../../domain/entities/weather_condition.dart';
import '../model/zone_dto.dart';
import '../model/alert_history_dto.dart';
import '../model/weather_dto.dart';

class CommunityMapper {
  static Zone zoneFromDto(ZoneDto dto) => Zone(
    id: dto.id,
    name: dto.name,
    municipality: dto.municipality,
    latitude: dto.latitude,
    longitude: dto.longitude,
    riskLevel: dto.riskLevel,
    mainCause: dto.mainCause,
    recommendation: dto.recommendation,
    lastUpdated: DateTime.parse(dto.lastUpdated),
  );

  static AlertHistory alertFromDto(AlertHistoryDto dto) => AlertHistory(
    id: dto.id,
    zoneName: dto.zoneName,
    riskLevel: dto.riskLevel,
    startDate: DateTime.parse(dto.startDate),
    endDate: dto.endDate != null ? DateTime.parse(dto.endDate!) : null,
    derivedToBrigade: dto.derivedToBrigade,
  );

  static WeatherCondition weatherFromDto(WeatherDto dto) => WeatherCondition(
    zoneId: dto.zoneId,
    temperature: dto.temperature,
    humidity: dto.humidity,
    windSpeed: dto.windSpeed,
    daysWithoutRain: dto.daysWithoutRain,
    explanation: dto.explanation,
    updatedAt: DateTime.parse(dto.updatedAt),
  );
}
