class WeatherDto {
  final String zoneId;
  final double temperature;
  final double humidity;
  final double windSpeed;
  final int daysWithoutRain;
  final String explanation;
  final String updatedAt;

  WeatherDto({
    required this.zoneId,
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.daysWithoutRain,
    required this.explanation,
    required this.updatedAt,
  });

  factory WeatherDto.fromJson(Map<String, dynamic> json) => WeatherDto(
    zoneId: json['zone_id'],
    temperature: (json['temperature'] as num).toDouble(),
    humidity: (json['humidity'] as num).toDouble(),
    windSpeed: (json['wind_speed'] as num).toDouble(),
    daysWithoutRain: json['days_without_rain'],
    explanation: json['explanation'],
    updatedAt: json['updated_at'],
  );
}
