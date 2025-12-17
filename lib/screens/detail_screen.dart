import 'package:flutter/material.dart';
import '../service/weather_service.dart';
import '../models/forecast_model.dart';
import '../widgets/forecast_title.dart';

class Weather {
  final double temperature;
  final double windSpeed;
  final String description;
  final int humidity;
  final int precipitation;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.description,
    required this.humidity,
    required this.precipitation,
  });
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weatherData;
  List<ForecastDay> _forecast = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Jakarta lat/lon
      final current = await _weatherService.getCurrentWeather(-6.2, 106.8);
      final forecastData = await _weatherService.getDailyForecast(-6.2, 106.8);
      final hourly = await _weatherService.getHourlyDetails(-6.2, 106.8);

      setState(() {
        _weatherData = Weather(
          temperature: (current['temperature'] as num).toDouble(),
          windSpeed: (current['windspeed'] as num).toDouble(),
          description: _mapWeatherCode(current['weathercode'] as int),
          humidity: hourly['humidity'] ?? 0,
          precipitation: hourly['precipitation'] ?? 0,
        );
        _forecast = forecastData;
        _errorMsg = null;
      });
    } catch (e) {
      setState(() {
        _errorMsg = "Gagal memuat data: $e";
      });
    }
  }

  // Mapping kode cuaca ke teks (lengkap)
  String _mapWeatherCode(int code) {
    switch (code) {
      case 0: return "Cerah";
      case 1:
      case 2:
      case 3: return "Berawan";
      case 45:
      case 48: return "Kabut";
      case 51:
      case 53:
      case 55: return "Gerimis";
      case 61:
      case 63:
      case 65: return "Hujan";
      case 66:
      case 67: return "Hujan beku";
      case 71:
      case 73:
      case 75: return "Salju";
      case 77: return "Salju granular";
      case 80:
      case 81:
      case 82: return "Hujan deras";
      case 85:
      case 86: return "Salju deras";
      case 95: return "Badai";
      case 96:
      case 99: return "Badai petir";
      default: return "Tidak diketahui";
    }
  }

  // Format tanggal ke Bahasa Indonesia
  String _formatDate(DateTime date) {
    final weekday = _weekdayName(date.weekday);
    final day = date.day;
    final month = _monthName(date.month);
    return '$weekday, $day $month';
  }

  String _weekdayName(int weekday) {
    const names = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    return names[weekday - 1]; // weekday: 1=Senin ... 7=Minggu
  }

  String _monthName(int month) {
    const names = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMsg != null) {
      return Center(
        child: Text(
          _errorMsg!,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }
    if (_weatherData == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatDate(DateTime.now()),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Fallback jika asset tidak ada
            Image.asset(
              'assets/images/cloud_rain_sun.png',
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.cloud, color: Colors.white, size: 64);
              },
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _weatherData!.description,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  '${_weatherData!.temperature.toStringAsFixed(0)}°  '
                  'Feels like ${(_weatherData!.temperature + 4).toStringAsFixed(0)}°',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text('Details', style: TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curah Endapan: ${_weatherData!.precipitation}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Curah Angin: ${_weatherData!.windSpeed.toStringAsFixed(0)} Km/h',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Kelembapan: ${_weatherData!.humidity}%',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Next Days', style: TextStyle(color: Colors.white, fontSize: 20)),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _forecast.length,
            itemBuilder: (context, index) {
              final day = _forecast[index];
              final formatted = _formatDate(day.date);
              final temp =
                  '${day.minTemp.toStringAsFixed(0)}° / ${day.maxTemp.toStringAsFixed(0)}°';

              return ForecastTile(
                day: formatted,
                temp: temp,
                condition: day.condition,
              );
            },
          ),
        ),
      ],
    );
  }
}