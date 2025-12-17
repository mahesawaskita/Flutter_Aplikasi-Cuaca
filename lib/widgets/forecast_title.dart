import 'package:flutter/material.dart';

class ForecastTile extends StatelessWidget {
  final String day;
  final String temp;
  final String condition;

  const ForecastTile({
    super.key,
    required this.day,
    required this.temp,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(day, style: const TextStyle(color: Colors.white)),
        subtitle: Text(condition, style: const TextStyle(color: Colors.white70)),
        trailing: Text(temp, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}