class WeatherCondition {
  final String zoneId;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int daysWithoutRain;
  final String explanation;
  final DateTime updatedAt;

  const WeatherCondition({
    required this.zoneId,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.daysWithoutRain,
    required this.explanation,
    required this.updatedAt,
  });
}
