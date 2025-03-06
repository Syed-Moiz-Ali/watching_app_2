import 'package:flutter/material.dart';

extension WidgetExtensions on Widget {
  /// Wraps the widget with padding
  Widget withPadding({double all = 8.0}) =>
      Padding(padding: EdgeInsets.all(all), child: this);

  /// Wraps the widget with a center widget
  Widget centered() => Center(child: this);

  /// Wraps the widget with an InkWell (useful for gestures)
  Widget onTap(VoidCallback onTap) =>
      GestureDetector(onTap: onTap, child: this);
}
