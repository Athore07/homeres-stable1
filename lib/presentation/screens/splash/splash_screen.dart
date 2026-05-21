// lib/presentation/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routing/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    // Show splash for at least 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
      final role = prefs.getString('user_role') ?? 'homeowner';

      if (!mounted) return;

      if (isLoggedIn) {
        // User is logged in - go directly to their role-based home
        final route = switch (role) {
          'admin' => RouteNames.adminDashboard,
          'technician' => RouteNames.technicianHome,
          _ => RouteNames.home,
        };
        context.go(route);
      } else if (onboardingComplete) {
        // User has seen onboarding but not logged in
        context.go(RouteNames.login);
      } else {
        // First time user
        context.go(RouteNames.onboarding);
      }
    } catch (e) {
      // On any error, go to onboarding as fallback
      if (mounted) context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_repair_service, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'HOMERES',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Home Repair Experts',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}