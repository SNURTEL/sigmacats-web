extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}


extension ObjectExt<T> on T {
  R let<R>(R Function(T it) op) => op(this);
}
