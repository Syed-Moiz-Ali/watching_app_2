import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Media query shortcuts
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get topPadding => MediaQuery.of(this).padding.top;
  double get bottomPadding => MediaQuery.of(this).padding.bottom;

  // Device orientation and size utilities
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
  bool get isPortrait =>
      MediaQuery.of(this).orientation == Orientation.portrait;

  // Date formatting utilities
  String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  String formatTime(DateTime time, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(time);
  }

  String formatDatetime(DateTime datetime,
      {String format = 'dd MMM yyyy, hh:mm a'}) {
    return DateFormat(format).format(datetime);
  }

  String getDayName(DateTime date, {bool abbreviated = true}) {
    return DateFormat(abbreviated ? 'E' : 'EEEE').format(date);
  }

  String getMonthName(DateTime date, {bool abbreviated = true}) {
    return DateFormat(abbreviated ? 'MMM' : 'MMMM').format(date);
  }

  // Snackbar and dialog utilities
  void showSnackBar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
      ),
    );
  }

  void showErrorSnackBar(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSuccessSnackBar(String message,
      {Duration duration = const Duration(seconds: 2)}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }

  // Currency formatting for prices
  String formatCurrency(double amount) {
    // You can customize this based on your app's currency format
    return '₹${amount.toStringAsFixed(2)}';
  }
}
