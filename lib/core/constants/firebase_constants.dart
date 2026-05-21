// lib/core/constants/firebase_constants.dart
class FirebaseConstants {
  // Collections
  static const String usersCollection = 'users';
  static const String techniciansCollection = 'technicians';
  static const String servicesCollection = 'services';
  static const String bookingsCollection = 'bookings';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';
  
  // User fields
  static const String userRole = 'role';
  static const String userEmail = 'email';
  static const String userName = 'name';
  static const String userPhone = 'phone';
  static const String userCreatedAt = 'createdAt';
  
  // User roles
  static const String roleHomeowner = 'homeowner';
  static const String roleTechnician = 'technician';
  static const String roleAdmin = 'admin';
}