// lib/core/constants/api_constants.dart
class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.homeres.com/v1';
  static const String mapsApiKey = '';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/update';
  static const String uploadImage = '/user/upload-image';
  
  // Technician endpoints
  static const String technicians = '/technicians';
  static const String technicianDetail = '/technicians/detail';
  static const String technicianVerification = '/technicians/verify';
  static const String technicianAvailability = '/technicians/availability';
  
  // Service endpoints
  static const String services = '/services';
  static const String serviceCategories = '/services/categories';
  
  // Booking endpoints
  static const String bookings = '/bookings';
  static const String createBooking = '/bookings/create';
  static const String updateBooking = '/bookings/update';
  static const String bookingStatus = '/bookings/status';
  
  // Review endpoints
  static const String reviews = '/reviews';
  static const String submitReview = '/reviews/submit';
  static const String technicianReviews = '/reviews/technician';
  
  // Notification endpoints
  static const String notifications = '/notifications';
  static const String markRead = '/notifications/mark-read';
  static const String unreadCount = '/notifications/unread';
  
  // Chat endpoints
  static const String chats = '/chats';
  static const String chatMessages = '/chats/messages';
  static const String sendMessage = '/chats/send';
  
  // Payment endpoints
  static const String payment = '/payment';
  static const String paymentMethods = '/payment/methods';
  static const String processPayment = '/payment/process';
  
  // Search endpoints
  static const String search = '/search';
  static const String searchTechnicians = '/search/technicians';
  
  // Settings endpoints
  static const String settings = '/settings';
  static const String updateSettings = '/settings/update';
}