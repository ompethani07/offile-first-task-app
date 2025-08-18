import 'package:flutter/material.dart';

Color strengthenColor(Color color, double strength) {
  int r = (color.red * strength).clamp(0, 255).toInt();
  int g = (color.green * strength).clamp(0, 255).toInt();
  int b = (color.blue * strength).clamp(0, 255).toInt();
  return Color.fromARGB(color.alpha, r, g, b);
}

List<DateTime> generateWeekDates(int weekOffset) {
  final today = DateTime.now();
  DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  startOfWeek = startOfWeek.add(Duration(days: weekOffset * 5));

  return List.generate(5, (index) => startOfWeek.add(Duration(days: index)));
}

String rgbToHex(Color color) {
  return '#${color.red.toRadixString(16).padLeft(2, '0')}${color.green.toRadixString(16).padLeft(2, '0')}${color.blue.toRadixString(16).padLeft(2, '0')}';
}

Color hexToRgb(String hexColor) {
  final hex = hexColor.replaceAll('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  } else if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  } else {
    throw FormatException('Invalid hex color format');
  }
}

Color hexToColor(String hex) {
  hex = hex.replaceAll('#', ''); // remove # if present
  if (hex.length == 6) {
    hex = 'FF$hex'; // add alpha if not provided
  }
  return Color(int.parse(hex, radix: 16));
}
