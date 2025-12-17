class ForecastDay {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String condition;

  ForecastDay({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.condition,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: json['temp']['min']?.toDouble() ?? 0.0,
      maxTemp: json['temp']['max']?.toDouble() ?? 0.0,
      condition: json['weather'][0]['main'] ?? '',
    );
  }
}