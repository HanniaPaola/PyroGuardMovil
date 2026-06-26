import '../entities/weather_condition.dart';
import '../repositories/community_repository.dart';

class GetWeatherConditionsUsecase {
  final CommunityRepository repository;

  GetWeatherConditionsUsecase(this.repository);

  Future<WeatherCondition> call(String zoneId) =>
      repository.getWeatherCondition(zoneId);
}
