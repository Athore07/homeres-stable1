// lib/presentation/screens/settings/admin_profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/section_header.dart';
import '../../../core/utils/validators.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  String? _profileImagePath;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
  }

  void _onChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  @override
  void dispose() { _nameController.dispose(); _emailController.dispose(); _phoneController.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (image != null) setState(() { _profileImagePath = image.path; _hasChanges = true; });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) { setState(() { _isSaving = false; _hasChanges = false; }); context.showSnackBar('Profile updated!'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile', style: TextStyle(fontWeight: FontWeight.bold)), actions: [
        if (_hasChanges) TextButton(onPressed: _saveProfile, child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold))),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Profile Photo
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(children: [
                  CircleAvatar(radius: 55, backgroundColor: AppColors.warning.withOpacity(0.1), backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null, child: _profileImagePath == null ? const Icon(Icons.admin_panel_settings, size: 50, color: AppColors.warning) : null),
                  Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 16))),
                ]),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Personal Info
            SectionHeader(title: 'Personal Information', accentColor: AppColors.warning),
            const SizedBox(height: 14),
            CustomTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person_outlined, validator: Validators.name),
            const SizedBox(height: 14),
            CustomTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email_outlined, enabled: false),
            const SizedBox(height: 14),
            CustomTextField(controller: _phoneController, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
            const SizedBox(height: 24),

            // Admin Info
            SectionHeader(title: 'Admin Information', accentColor: AppColors.error),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withOpacity(0.1))),
              child: Column(children: [
                _InfoRow(label: 'Role', value: 'System Administrator'),
                _InfoRow(label: 'Access Level', value: 'Full Access'),
                _InfoRow(label: 'Last Login', value: 'Today'),
                _InfoRow(label: 'Account Status', value: 'Active'),
              ]),
            ),
            const SizedBox(height: 24),

            // Security
            SectionHeader(title: 'Security', accentColor: AppColors.primary),
            const SizedBox(height: 14),
            _SecurityTile(icon: Icons.security, title: 'Two-Factor Authentication', value: true, onChanged: (_) {}),
            _SecurityTile(icon: Icons.visibility, title: 'Activity Log', value: true, onChanged: (_) {}),
            _SecurityTile(icon: Icons.notifications, title: 'Security Alerts', value: true, onChanged: (_) {}),
            const SizedBox(height: 24),

            if (_hasChanges) CustomButton(label: 'Save Changes', onPressed: _saveProfile, isLoading: _isSaving),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ]),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SecurityTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.warning, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.warning,
    );
  }
}