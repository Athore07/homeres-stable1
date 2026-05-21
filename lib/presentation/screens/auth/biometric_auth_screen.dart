// lib/presentation/screens/auth/biometric_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class BiometricAuthScreen extends StatelessWidget {
  const BiometricAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.gradientPrimary,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // App logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.home_repair_service, size: 50, color: AppColors.primary),
              ).animate().fadeIn(duration: 600.ms),
              const SizedBox(height: 32),
              Text(
                'HOMERES',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const Spacer(),
              // Fingerprint icon
              GestureDetector(
                onTap: () {
                  // Simulate biometric auth
                  Future.delayed(const Duration(seconds: 1), () {
                    if (context.mounted) {
                      context.go('/home');
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.1),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    size: 80,
                    color: Colors.white,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    duration: 1500.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                  )
                  .then()
                  .scale(
                    duration: 1500.ms,
                    begin: const Offset(1.1, 1.1),
                    end: const Offset(1, 1),
                  ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Touch the fingerprint sensor',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 48),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Use Password Instead',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}