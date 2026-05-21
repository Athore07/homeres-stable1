// lib/presentation/screens/settings/homeowner_profile_screen.dart
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

class HomeownerProfileScreen extends ConsumerStatefulWidget {
  const HomeownerProfileScreen({super.key});

  @override
  ConsumerState<HomeownerProfileScreen> createState() => _HomeownerProfileScreenState();
}

class _HomeownerProfileScreenState extends ConsumerState<HomeownerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  
  String? _profileImagePath;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final user = authState.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: '');
    
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
    _addressController.addListener(_onChanged);
  }

  void _onChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose();
    _phoneController.dispose(); _addressController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)), actions: [
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
                  CircleAvatar(radius: 55, backgroundColor: AppColors.primary.withOpacity(0.1), backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null, child: _profileImagePath == null ? const Icon(Icons.person, size: 50, color: AppColors.primary) : null),
                  Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 16))),
                ]),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Personal Info
            SectionHeader(title: 'Personal Information', accentColor: AppColors.primary),
            const SizedBox(height: 14),
            CustomTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person_outlined, validator: Validators.name),
            const SizedBox(height: 14),
            CustomTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email_outlined, enabled: false),
            const SizedBox(height: 14),
            CustomTextField(controller: _phoneController, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
            const SizedBox(height: 24),

            // Address
            SectionHeader(title: 'Address', accentColor: AppColors.success),
            const SizedBox(height: 14),
            CustomTextField(controller: _addressController, label: 'Home Address', prefixIcon: Icons.location_on_outlined, maxLines: 2),
            const SizedBox(height: 24),

            // Homeowner Specific
            SectionHeader(title: 'Preferences', accentColor: AppColors.accent),
            const SizedBox(height: 14),
            _PreferenceTile(icon: Icons.notifications, title: 'Service Reminders', value: true, onChanged: (_) {}),
            _PreferenceTile(icon: Icons.email, title: 'Email Updates', value: false, onChanged: (_) {}),
            _PreferenceTile(icon: Icons.location_on, title: 'Location Services', value: true, onChanged: (_) {}),
            const SizedBox(height: 24),

            if (_hasChanges) CustomButton(label: 'Save Changes', onPressed: _saveProfile, isLoading: _isSaving),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PreferenceTile({required this.icon, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}