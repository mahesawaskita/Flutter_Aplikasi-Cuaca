import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';

class WeatherService {
  final String baseUrl = "https://api.open-meteo.com/v1/forecast";

  /// Ambil cuaca saat ini (current weather)
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final url = Uri.parse(
      "$baseUrl?latitude=$lat&longitude=$lon&current_weather=true&timezone=Asia%2FJakarta",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['current_weather'];
      // contoh: {temperature: 30.2, windspeed: 5.1, weathercode: 2, ...}
    } else {
      throw Exception("Gagal ambil data cuaca: ${response.statusCode}");
    }
  }

  /// Ambil forecast harian (7 hari)
  Future<List<ForecastDay>> getDailyForecast(double lat, double lon) async {
    final url = Uri.parse(
      "$baseUrl?latitude=$lat&longitude=$lon&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=Asia%2FJakarta",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List dates = data['daily']['time'];
      final List tempsMin = data['daily']['temperature_2m_min'];
      final List tempsMax = data['daily']['temperature_2m_max'];
      final List codes = data['daily']['weathercode'];

      return List.generate(dates.length, (index) {
        return ForecastDay(
          date: DateTime.parse(dates[index]),
          minTemp: tempsMin[index].toDouble(),
          maxTemp: tempsMax[index].toDouble(),
          condition: _mapWeatherCode(codes[index]),
        );
      });
    } else {
      throw Exception("Gagal ambil data forecast: ${response.statusCode}");
    }
  }

  /// Mapping kode cuaca Open-Meteo ke teks (lengkap)
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

  /// Ambil kelembapan dan curah hujan dari hourly data
Future<Map<String, dynamic>> getHourlyDetails(double lat, double lon) async {
  final url = Uri.parse(
    "$baseUrl?latitude=$lat&longitude=$lon&hourly=relative_humidity_2m,precipitation&timezone=Asia%2FJakarta",
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final humidityList = data['hourly']['relative_humidity_2m'];
    final precipitationList = data['hourly']['precipitation'];

    // Ambil data terakhir (jam terbaru)
    final humidity = (humidityList.last as num).toInt();
    final precipitation = (precipitationList.last as num).toInt();

    return {
      'humidity': humidity,
      'precipitation': precipitation,
    };
  } else {
    throw Exception("Gagal ambil data kelembapan dan curah hujan: ${response.statusCode}");
  }
}

}