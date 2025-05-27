import 'package:flutter/material.dart';

class TabContent {
  final int? notificationCount;
  final double? progress; // 0-100
  final bool? hasNewContent;
  final IconData? lengthIcon;
  final String? subtitle;
  final String title;
  final String length;
  final dynamic icon;
  final Color? badgeColor;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;

  TabContent({
    required this.title,
    required this.length,
    required this.icon,
    this.notificationCount,
    this.progress,
    this.hasNewContent,
    this.lengthIcon,
    this.subtitle,
    this.badgeColor,
    this.onLongPress,
    this.onDoubleTap,
  });
}
