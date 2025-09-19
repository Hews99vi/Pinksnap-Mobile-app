import 'package:flutter/material.dart';

/// Extension methods for Color class
extension ColorExtension on Color {
  /// Returns a new color with modified values (alpha, red, green, blue)
  Color withValues({int? alpha, int? red, int? green, int? blue}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}
