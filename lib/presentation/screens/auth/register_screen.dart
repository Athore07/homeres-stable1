// lib/presentation/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/utils/validators.dart';
import '../../../routing/route_names.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/app_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = FirebaseConstants.roleHomeowner;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    try {
      await ref.read(authProvider.notifier).register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Registration failed. Please try again.', isError: true);
      }
    }
}

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isTechnician = _selectedRole == FirebaseConstants.roleTechnician;

ref.listen<AuthState>(authProvider, (previous, next) {
       if (previous?.user == null && next.user != null) {
         if (next.user?.role == FirebaseConstants.roleTechnician) {
           context.go(RouteNames.profileSetup);
         }
       }
       if (next.error != null && previous?.error != next.error) {
         context.showSnackBar(next.error ?? 'Error', isError: true);
         ref.read(authProvider.notifier).clearError();
       }
     });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => context.pop()),
        title: const Text('Create Account', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // App Logo
              const AppLogo(size: 80, showText: false)
                  .animate().fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
              
              const SizedBox(height: 24),

              Text('Create Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold))
                  .animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 4),
              Text(isTechnician ? 'Register as a service provider' : 'Fill in the details to get started', 
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textHint))
                  .animate().fadeIn(duration: 400.ms, delay: 100.ms),
              
              const SizedBox(height: 28),

              // Name
              CustomTextField(controller: _nameController, label: 'Full Name', hint: 'Enter your full name', prefixIcon: Icons.person_outlined, validator: Validators.name)
                  .animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: -20),
              const SizedBox(height: 14),

              // Email
              CustomTextField(controller: _emailController, label: 'Email', hint: 'Enter your email', prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: Validators.email)
                  .animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: 20),
              const SizedBox(height: 14),

              // Phone
              CustomTextField(controller: _phoneController, label: 'Phone Number', hint: 'Enter your phone number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone)
                  .animate().fadeIn(duration: 400.ms, delay: 400.ms).slideX(begin: -20),
              const SizedBox(height: 14),

              // Role Selection
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(child: _RoleChip(label: 'Homeowner', role: FirebaseConstants.roleHomeowner, icon: Icons.home_rounded, selected: _selectedRole == FirebaseConstants.roleHomeowner, onTap: () => setState(() => _selectedRole = FirebaseConstants.roleHomeowner))),
                  Expanded(child: _RoleChip(label: 'Technician', role: FirebaseConstants.roleTechnician, icon: Icons.engineering_rounded, selected: _selectedRole == FirebaseConstants.roleTechnician, onTap: () => setState(() => _selectedRole = FirebaseConstants.roleTechnician))),
                ]),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

              // Technician Info Banner
              if (isTechnician)
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.info.withValues(alpha: 0.2))),
                  child: Row(children: [
                    const Icon(Icons.info_outline, color: AppColors.info, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text('After registration, you\'ll set up your professional profile with skills, certifications, and rates.', style: TextStyle(color: AppColors.info.withValues(alpha: 0.8), fontSize: 11))),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

              const SizedBox(height: 14),

              // Password
              CustomTextField(
                controller: _passwordController, label: 'Password', hint: 'Create a password', prefixIcon: Icons.lock_outlined, obscureText: _obscurePassword,
                suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                validator: Validators.password,
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideX(begin: 20),
              const SizedBox(height: 14),

              // Confirm Password
              CustomTextField(
                controller: _confirmPasswordController, label: 'Confirm Password', hint: 'Confirm your password', prefixIcon: Icons.lock_outlined, obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm your password';
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideX(begin: -20),
              
              const SizedBox(height: 28),

              // Register Button
              CustomButton(
                label: isTechnician ? 'Register & Continue to Profile' : 'Create Account',
                onPressed: authState.isLoading ? null : _handleRegister,
                isLoading: authState.isLoading,
              ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
              
              const SizedBox(height: 20),

              // Login Link
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                GestureDetector(onTap: () => context.pop(), child: const Text('Sign In', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
              ]).animate().fadeIn(duration: 400.ms, delay: 900.ms),
              
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

// Role Chip Widget
class _RoleChip extends StatelessWidget {
  final String label;
  final String role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({required this.label, required this.role, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 24, color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: selected ? Colors.white : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600, fontSize: 13)),
        ]),
      ),
    );
  }
}