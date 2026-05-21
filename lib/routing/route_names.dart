// lib/routing/route_names.dart
class RouteNames {
  // Splash & Onboarding
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String otpVerification = '/auth/otp';
  
  // Homeowner
  static const String home = '/home';
  static const String serviceList = '/services';
  static const String serviceDetail = '/services/list';
  static const String booking = '/booking';
  static const String bookingHistory = '/booking/history';
  static const String tracking = '/tracking';
  static const String review = '/review';
  static const String favorites = '/favorites';
  
  // Technician
  static const String technicianHome = '/technician/home';
  static const String profileSetup = '/technician/profile-setup';
  static const String jobRequests = '/technician/jobs';
  static const String earnings = '/technician/earnings';
  static const String schedule = '/technician/schedule';
  
  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String manageUsers = '/admin/users';
  static const String manageTechnicians = '/admin/technicians';
  static const String manageServices = '/admin/services';
  static const String analytics = '/admin/analytics';
  
  // Settings
  static const String settings = '/settings';
  // Role-based profile screens
  static const String adminProfileScreen = '/settings/admin-profile';
  static const String technicianProfileScreen = '/settings/technician-profile';
  static const String homeownerProfileScreen = '/settings/homeowner-profile';

  
  static const String changePassword = '/settings/password';
  static const String notifications = '/settings/notifications';
  static const String language = '/settings/language';
  static const String theme = '/settings/theme';
  static const String privacyPolicy = '/settings/privacy';
  static const String termsConditions = '/settings/terms';
  static const String about = '/settings/about';
  static const String helpSupport = '/settings/help';
  static const String adminSettings = '/settings/admin';
  
  
  // Features
  static const String search = '/search';
  static const String filter = '/filter';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/detail';
  static const String payment = '/payment';
  static const String paymentMethods = '/payment/methods';
  
  static const String invoice = '/payment/invoice';
  static const String bookingDetail = '/booking/detail';
}