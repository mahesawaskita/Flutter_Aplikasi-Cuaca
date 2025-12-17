class Weather {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final double precipitation;

  Weather({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.precipitation,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['main']['temp']?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: json['wind']['speed']?.toDouble() ?? 0.0,
      precipitation: json['rain']?['1h']?.toDouble() ?? 0.0,
    );
  }
}