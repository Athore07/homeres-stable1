// lib/presentation/screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _timer = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timer > 0) {
        setState(() => _timer--);
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, size: 48, color: AppColors.primary),
            ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.5, 0.5),
              curve: Curves.elasticOut,
            ),
            const SizedBox(height: 32),
            Text(
              'Verify Phone Number',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              'We have sent a verification code to\n+255 712 345 678',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textHint,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 40),
            
            // OTP fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ).animate().fadeIn(
                  duration: 400.ms,
                  delay: Duration(milliseconds: 400 + (index * 100)),
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  delay: Duration(milliseconds: 400 + (index * 100)),
                );
              }),
            ),
            const SizedBox(height: 32),
            
            // Timer and resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive code? ",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_timer > 0)
                  Text(
                    'Resend in ${_timer}s',
                    style: const TextStyle(color: AppColors.textHint),
                  )
                else
                  GestureDetector(
                    onTap: () {
                      setState(() => _timer = 60);
                      _startTimer();
                      context.showSnackBar('Code resent successfully');
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
            const SizedBox(height: 32),
            
            // Verify button
            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ).animate().fadeIn(duration: 400.ms, delay: 1100.ms),
          ],
        ),
      ),
    );
  }
}