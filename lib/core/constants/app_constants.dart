// lib/core/constants/app_constants.dart
class AppConstants {
  // App Info
  static const String appName = 'HOMERES';
  static const String appTagline = 'Home Repair Experts';
  static const String appVersion = '1.0.0';
  
  // Firebase Configuration
  static const String firebaseApiKey = 'AIzaSyB_Gwrd9hMSTsyT4lVfqwAUsfMXW9jqEwA';
  static const String firebaseAppId = '1:582383325535:android:258656bc31b24557a4e6ea';
  static const String firebaseMessagingSenderId = '582383325535';
  static const String firebaseProjectId = 'style-f5ece';
  static const String firebaseStorageBucket = 'style-f5ece.firebasestorage.app';
  static const String firebaseProjectNumber = '582383325535';
  // API
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  
  // Default Location (Dar es Salaam, Tanzania)
  static const double defaultLatitude = -6.369028;
  static const double defaultLongitude = 34.888822;
  static const double searchRadius = 50.0;
}