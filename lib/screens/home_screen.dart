import 'package:flutter/material.dart';
import '../service/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      // Jakarta lat/lon
      final data = await _weatherService.getCurrentWeather(-6.2, 106.8);
      setState(() {
        _weatherData = data;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF1E88E5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Jakarta Barat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.search, color: Colors.white, size: 28),
              ],
            ),
            const SizedBox(height: 40),
            Image.asset('assets/images/awan.png', height: 150),
            const SizedBox(height: 20),

            // Jika data belum ada, tampilkan loading
            _weatherData == null
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    children: [
                      Text(
                        "${_weatherData!['temperature']}°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _mapWeatherCode(_weatherData!['weathercode']),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),

            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/detail');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  String _mapWeatherCode(int code) {
    switch (code) {
      case 0:
        return "Cerah";
      case 1:
      case 2:
      case 3:
        return "Berawan";
      case 45:
      case 48:
        return "Kabut";
      case 51:
      case 53:
      case 55:
        return "Gerimis";
      case 61:
      case 63:
      case 65:
        return "Hujan";
      case 95:
        return "Badai";
      default:
        return "Tidak diketahui";
    }
  }
}
