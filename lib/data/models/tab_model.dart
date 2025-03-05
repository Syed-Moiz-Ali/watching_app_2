import 'package:flutter/material.dart';

// Model class for Tab content
class TabContent {
  final String title;
  final dynamic icon;
  final Color? color;

  TabContent({
    required this.title,
    required this.icon,
    this.color,
  });
}
