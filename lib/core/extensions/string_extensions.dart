// lib/core/extensions/string_extensions.dart
extension StringExtensions on String {
  String get capitalize => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  
  String get capitalizeEachWord => split(' ').map((word) => word.capitalize).join(' ');
  
  String get initials {
    final parts = split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return substring(0, 1).toUpperCase();
  }
  
  bool get isValidEmail => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  
  bool get isValidPhone => RegExp(r'^\+?[0-9]{10,15}$').hasMatch(this);
  
  bool get isValidPassword => length >= 6;
  
  String truncate(int maxLength) => length > maxLength ? '${substring(0, maxLength)}...' : this;
  
  String get toTitleCase => split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : '').join(' ');
}