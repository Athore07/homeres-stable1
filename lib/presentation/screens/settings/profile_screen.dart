// lib/presentation/screens/settings/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../../core/utils/validators.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;

  String? _profileImagePath;
  String? _profileImageUrl;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final user = authState.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: '');
    _bioController = TextEditingController(text: '');
    _profileImageUrl = user?.profileImage;

    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
    _addressController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
  }

  void _onChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose();
    _phoneController.dispose(); _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (image != null) setState(() { _profileImagePath = image.path; _hasChanges = true; });
    } catch (_) {
      if (mounted) context.showSnackBar('Failed to pick image');
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Profile Photo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(children: [
              _PickerOption(icon: Icons.camera_alt, label: 'Camera', color: AppColors.primary, onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
              const SizedBox(width: 16),
              _PickerOption(icon: Icons.photo_library, label: 'Gallery', color: AppColors.accent, onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
            ]),
            if (_profileImagePath != null || _profileImageUrl != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(onPressed: () { Navigator.pop(context); setState(() { _profileImagePath = null; _profileImageUrl = null; _hasChanges = true; }); }, icon: const Icon(Icons.delete, color: AppColors.error), label: const Text('Remove Photo', style: TextStyle(color: AppColors.error))),
            ],
          ]),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) { setState(() { _isLoading = false; _hasChanges = false; }); context.showSnackBar('Profile updated!'); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(slivers: [
        // Hero Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight)),
            child: Column(children: [
              Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                const Spacer(),
                if (_hasChanges) TextButton(onPressed: _saveProfile, child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
              ]),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _showImagePicker,
                child: Stack(children: [
                  Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 4), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)]),
                    child: CircleAvatar(
                      radius: 55, backgroundColor: Colors.white,
                      backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : (_profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null) as ImageProvider<Object>?,
                      child: _profileImagePath == null && _profileImageUrl == null ? Text(_nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: AppColors.primary)) : null,
                    ),
                  ),
                  Positioned(bottom: 4, right: 4, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 18))),
                ]),
              ),
            ]),
          ),
        ),

        // Form Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(children: [
                _SectionCard(
                  icon: Icons.person_rounded, color: AppColors.primary, title: 'Personal Info',
                  child: Column(children: [
                    CustomTextField(controller: _nameController, label: 'Full Name', hint: 'Enter your full name', prefixIcon: Icons.person_outlined, validator: Validators.name),
                    const SizedBox(height: 14),
                    CustomTextField(controller: _emailController, label: 'Email', hint: 'Your email', prefixIcon: Icons.email_outlined, enabled: false, suffixIcon: const Icon(Icons.verified, color: AppColors.success, size: 18)),
                  ]),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.phone_rounded, color: AppColors.success, title: 'Contact',
                  child: Column(children: [
                    CustomTextField(controller: _phoneController, label: 'Phone Number', hint: 'Enter your phone', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
                    const SizedBox(height: 14),
                    CustomTextField(controller: _addressController, label: 'Address', hint: 'Enter your address', prefixIcon: Icons.location_on_outlined, maxLines: 2),
                  ]),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  icon: Icons.info_outline_rounded, color: AppColors.accent, title: 'About You',
                  child: CustomTextField(controller: _bioController, label: 'Bio', hint: 'Tell us about yourself...', prefixIcon: Icons.edit_note, maxLines: 3),
                ),
                const SizedBox(height: 24),
                // Danger Zone
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(0.3))),
                  child: Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_forever, color: AppColors.error, size: 22)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Permanently remove all data', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ])),
                    TextButton(onPressed: () => ConfirmationDialog.show(context, title: 'Delete Account', message: 'This cannot be undone. All your data will be permanently deleted.', confirmLabel: 'Delete', confirmColor: AppColors.error, icon: Icons.delete_forever, isDestructive: true, onConfirm: () => context.showSnackBar('Account deletion requested')), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                  ]),
                ),
                if (_hasChanges) ...[const SizedBox(height: 20), CustomButton(label: 'Save Changes', onPressed: _saveProfile, isLoading: _isLoading)],
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// Picker Option
class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
          child: Column(children: [Icon(icon, color: color, size: 32), const SizedBox(height: 8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600))]),
        ),
      ),
    );
  }
}

// Section Card
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.color, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.08)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)), const SizedBox(width: 10), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}