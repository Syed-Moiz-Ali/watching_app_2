extension StringExtensions on String {
  /// Capitalizes the first letter of a string
  String get capitalize =>
      isEmpty ? "" : "${this[0].toUpperCase()}${substring(1)}";

  /// Converts snake_case to camelCase
  String get toCamelCase => split('_').map((word) => word.capitalize).join();

  /// Checks if the string is a valid email
  bool get isValidEmail {
    final regex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return regex.hasMatch(this);
  }

  /// Removes extra white spaces
  String get trimSpaces => replaceAll(RegExp(r"\s+"), " ").trim();
}
