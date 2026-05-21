// lib/presentation/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../di/injection_container.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await authRepository.sendPasswordResetEmail(
          _emailController.text.trim(),
        );
        if (mounted) {
          context.showSnackBar('Password reset email sent successfully');
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          context.showSnackBar(e.toString(), isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.lock_reset,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ).animate().fadeIn(duration: 400.ms).scale(
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut,
                ),
                const SizedBox(height: 32),
                Text(
                  'Reset Password',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 12),
                Text(
                  'Enter your email address and we will send you instructions to reset your password',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Send Reset Link',
                  onPressed: _handleResetPassword,
                  isLoading: _isLoading,
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}