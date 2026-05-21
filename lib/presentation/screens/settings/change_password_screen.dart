// lib/presentation/screens/settings/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../../core/utils/validators.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _isLoading = false);
        context.showSnackBar('Password changed successfully');
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Security icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.primary,
                ),
              ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.5, 0.5),
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                hint: 'Enter current password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscureCurrent,
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                validator: Validators.password,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: 'New Password',
                hint: 'Enter new password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscureNew,
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                validator: Validators.password,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                hint: 'Confirm new password',
                prefixIcon: Icons.lock_outlined,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Update Password',
                onPressed: _changePassword,
                isLoading: _isLoading,
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ],
          ),
        ),
      ),
    );
  }
}