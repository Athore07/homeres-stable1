// lib/presentation/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/app_logo.dart';
import '../../../routing/route_names.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Login failed. Please try again', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        context.showSnackBar(next.error!, isError: true);
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // App Logo
                const AppLogo(size: 100, showText: false)
                    .animate().fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),

                const SizedBox(height: 32),

                // Welcome
                Text('Welcome Back', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center)
                    .animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 8),

                Text('Sign in to continue', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textHint), textAlign: TextAlign.center)
                    .animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 40),

                // Email
                CustomTextField(
                  controller: _emailController, label: 'Email', hint: 'Enter your email',
                  prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email,
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -20),

                const SizedBox(height: 16),

                // Password
                CustomTextField(
                  controller: _passwordController, label: 'Password', hint: 'Enter your password',
                  prefixIcon: Icons.lock_outlined, obscureText: _obscurePassword,
                  suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  validator: Validators.password, onSubmitted: (_) => _handleLogin(),
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideX(begin: 20),

                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    SizedBox(height: 24, width: 24, child: Checkbox(value: _rememberMe, onChanged: (v) => setState(() => _rememberMe = v ?? false), activeColor: AppColors.primary)),
                    const SizedBox(width: 8),
                    Text('Remember me', style: Theme.of(context).textTheme.bodySmall),
                  ]),
                  TextButton(onPressed: () => context.push(RouteNames.forgotPassword), child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13))),
                ]).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 24),

                // Login Button
                CustomButton(label: 'Sign In', onPressed: authState.isLoading ? null : _handleLogin, isLoading: authState.isLoading)
                    .animate().fadeIn(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 24),

                // Register Link
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(onTap: () => context.push(RouteNames.register), child: const Text('Sign Up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
                ]).animate().fadeIn(duration: 400.ms, delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}