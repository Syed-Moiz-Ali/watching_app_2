extension ListExtensions<T> on List<T> {
  /// Returns the last element or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Returns the first element or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Checks if the list contains a specific element
  bool containsElement(T element) => contains(element);

  /// Shuffles the list (useful for randomizing lists)
  List<T> get shuffled => [...this]..shuffle();
}
