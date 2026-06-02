// lib/routing/app_router.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/providers/auth/auth_provider.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_shell.dart';
import '../presentation/screens/admin/analytics_screen.dart';
import '../presentation/screens/admin/manage_services_screen.dart';
import '../presentation/screens/admin/manage_technicians_screen.dart';
import '../presentation/screens/admin/manage_users_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/chat/chat_list_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/homeowner/booking_history_screen.dart';
import '../presentation/screens/homeowner/booking_screen.dart';
import '../presentation/screens/homeowner/favorite_technicians_screen.dart';
import '../presentation/screens/homeowner/home_screen.dart';
import '../presentation/screens/homeowner/homeowner_shell.dart';
import '../presentation/screens/homeowner/review_screen.dart';
import '../presentation/screens/homeowner/service_list_screen.dart';
import '../presentation/screens/homeowner/tracking_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/settings/about_screen.dart';
import '../presentation/screens/settings/admin_profile_screen.dart';
import '../presentation/screens/settings/change_password_screen.dart';
import '../presentation/screens/settings/help_support_screen.dart';
import '../presentation/screens/settings/homeowner_profile_screen.dart';
import '../presentation/screens/settings/language_screen.dart';
import '../presentation/screens/settings/privacy_policy_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/settings/technician_profile_screen.dart';
import '../presentation/screens/settings/theme_screen.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/technician/earnings_screen.dart';
import '../presentation/screens/technician/job_requests_screen.dart';
import '../presentation/screens/technician/profile_setup_screen.dart';
import '../presentation/screens/technician/schedule_screen.dart';
import '../presentation/screens/technician/technician_home_screen.dart';
import '../presentation/screens/technician/technician_shell.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final isLoggedIn = authState.user != null;

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
       final isAuthRoute = state.matchedLocation.contains('/auth');
       final isSplash = state.matchedLocation == RouteNames.splash;
       final isOnboarding = state.matchedLocation == RouteNames.onboarding;

       if (isSplash || isOnboarding) {
         return isLoggedIn ? _getHomeRoute(authState.user?.role ?? 'homeowner') : null;
       }

       if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
       if (isLoggedIn && isAuthRoute) {
         return _getHomeRoute(authState.user?.role ?? 'homeowner');
       }
       return null;
     },
    routes: [
      // ==================== Splash & Onboarding ====================
      GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: RouteNames.onboarding, builder: (_, _) => const OnboardingScreen()),

      // ==================== Auth Routes ====================
      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: RouteNames.forgotPassword, builder: (_, _) => const ForgotPasswordScreen()),

      // ==================== Standalone Settings (no shell) ====================
      // Settings is accessible from all roles and handles navigation back automatically
      GoRoute(
        path: RouteNames.settings,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          // Profile screens nested under settings
          GoRoute(path: 'admin-profile', builder: (_, _) => const AdminProfileScreen()),
          GoRoute(path: 'technician-profile', builder: (_, _) => const TechnicianProfileScreen()),
          GoRoute(path: 'homeowner-profile', builder: (_, _) => const HomeownerProfileScreen()),
          // Settings sub-routes
          GoRoute(path: 'password', builder: (_, _) => const ChangePasswordScreen()),
          GoRoute(path: 'language', builder: (_, _) => const LanguageScreen()),
          GoRoute(path: 'theme', builder: (_, _) => const ThemeScreen()),
          GoRoute(path: 'about', builder: (_, _) => const AboutScreen()),
          GoRoute(path: 'help', builder: (_, _) => const HelpSupportScreen()),
          GoRoute(path: 'privacy', builder: (_, _) => const PrivacyPolicyScreen()),
          GoRoute(path: 'terms', builder: (_, _) => const TermsConditionsScreen()),
        ],
      ),

      // ==================== Homeowner Routes ====================
      ShellRoute(
          builder: (context, state, child) => HomeownerShell(child: child),
        routes: [
          GoRoute(path: RouteNames.home, builder: (_, _) => const HomeScreen()),
          GoRoute(path: RouteNames.serviceList, builder: (_, _) => const ServiceListScreen()),
          GoRoute(path: RouteNames.booking, builder: (_, _) => const BookingScreen()),
          GoRoute(path: RouteNames.bookingHistory, builder: (_, _) => const BookingHistoryScreen()),
          GoRoute(path: RouteNames.favorites, builder: (_, _) => const FavoriteTechniciansScreen()),
          GoRoute(path: RouteNames.review, builder: (_, _) => const ReviewScreen()),
          GoRoute(path: RouteNames.tracking, builder: (_, _) => const TrackingScreen(bookingId: '',)),
          GoRoute(path: RouteNames.notifications, builder: (_, _) => const NotificationsScreen()),
        ],
      ),

      // ==================== Technician Routes ====================
      ShellRoute(
        builder: (context, state, child) => TechnicianShell(child: child),
        routes: [
          GoRoute(path: RouteNames.technicianHome, builder: (_, _) => const TechnicianHomeScreen()),
          GoRoute(path: RouteNames.profileSetup, builder: (_, _) => const ProfileSetupScreen()),
          GoRoute(path: RouteNames.jobRequests, builder: (_, _) => const JobRequestsScreen()),
          GoRoute(path: RouteNames.schedule, builder: (_, _) => const ScheduleScreen()),
          GoRoute(path: RouteNames.earnings, builder: (_, _) => const EarningsScreen()),
          GoRoute(path: RouteNames.notifications, builder: (_, _) => const NotificationsScreen()),
        ],
      ),

      // ==================== Admin Routes ====================
      ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: RouteNames.adminDashboard, builder: (_, _) => const AdminDashboardScreen()),
          GoRoute(path: RouteNames.manageUsers, builder: (_, _) => const ManageUsersScreen()),
          GoRoute(path: RouteNames.manageTechnicians, builder: (_, _) => const ManageTechniciansScreen()),
          GoRoute(path: RouteNames.manageServices, builder: (_, _) => const ManageServicesScreen()),
          GoRoute(path: RouteNames.analytics, builder: (_, _) => const AnalyticsScreen()),
          GoRoute(path: RouteNames.notifications, builder: (_, _) => const NotificationsScreen()),
        ],
      ),

      // ==================== Chat Routes (standalone, no shell) ====================
      GoRoute(path: RouteNames.chatList, builder: (_, _) => const ChatListScreen()),
      GoRoute(path: RouteNames.chatDetail, builder: (_, _) => const ChatScreen()),
    ],
  );
});

String _getHomeRoute(String role) => switch (role) {
  'technician' => RouteNames.technicianHome,
  'admin' => RouteNames.adminDashboard,
  _ => RouteNames.home,
};