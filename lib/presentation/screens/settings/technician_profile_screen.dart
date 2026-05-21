// lib/presentation/screens/settings/technician_profile_screen.dart
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

class TechnicianProfileScreen extends ConsumerStatefulWidget {
  const TechnicianProfileScreen({super.key});

  @override
  ConsumerState<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends ConsumerState<TechnicianProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _experienceController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _aboutController;
  
  String? _profileImagePath;
  bool _hasChanges = false;
  bool _isSaving = false;

  final List<String> _selectedSkills = [];
  static const _skillsList = ['Wiring', 'Circuit Breaker', 'Pipe Repair', 'Drain Cleaning', 'Fridge Repair', 'AC Service', 'Outlet Installation'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _specialtyController = TextEditingController();
    _experienceController = TextEditingController();
    _hourlyRateController = TextEditingController();
    _aboutController = TextEditingController();
    
    _nameController.addListener(_onChanged);
    _phoneController.addListener(_onChanged);
    _specialtyController.addListener(_onChanged);
    _experienceController.addListener(_onChanged);
    _hourlyRateController.addListener(_onChanged);
    _aboutController.addListener(_onChanged);
  }

  void _onChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  @override
  void dispose() {
    _nameController.dispose(); _emailController.dispose(); _phoneController.dispose();
    _specialtyController.dispose(); _experienceController.dispose();
    _hourlyRateController.dispose(); _aboutController.dispose();
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
      appBar: AppBar(title: const Text('Technician Profile', style: TextStyle(fontWeight: FontWeight.bold)), actions: [
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
                  CircleAvatar(radius: 55, backgroundColor: AppColors.info.withOpacity(0.1), backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null, child: _profileImagePath == null ? const Icon(Icons.engineering, size: 50, color: AppColors.info) : null),
                  Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.info, shape: BoxShape.circle), child: const Icon(Icons.camera_alt, color: Colors.white, size: 16))),
                ]),
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 28),

            // Personal Info
            SectionHeader(title: 'Personal Information', accentColor: AppColors.info),
            const SizedBox(height: 14),
            CustomTextField(controller: _nameController, label: 'Full Name', prefixIcon: Icons.person_outlined, validator: Validators.name),
            const SizedBox(height: 14),
            CustomTextField(controller: _emailController, label: 'Email', prefixIcon: Icons.email_outlined, enabled: false),
            const SizedBox(height: 14),
            CustomTextField(controller: _phoneController, label: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: Validators.phone),
            const SizedBox(height: 24),

            // Professional Info
            SectionHeader(title: 'Professional Details', accentColor: AppColors.success),
            const SizedBox(height: 14),
            CustomTextField(controller: _specialtyController, label: 'Specialty', hint: 'e.g., Electrician', prefixIcon: Icons.engineering),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: CustomTextField(controller: _experienceController, label: 'Experience (Years)', prefixIcon: Icons.work_history, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: CustomTextField(controller: _hourlyRateController, label: 'Hourly Rate (\$)', prefixIcon: Icons.attach_money, keyboardType: TextInputType.number)),
            ]),
            const SizedBox(height: 24),

            // Skills
            SectionHeader(title: 'Skills', accentColor: AppColors.accent),
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: _skillsList.map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return ChoiceChip(label: Text(skill), selected: isSelected, onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                  _hasChanges = true;
                });
              });
            }).toList()),
            const SizedBox(height: 24),

            // About
            SectionHeader(title: 'About', accentColor: AppColors.primary),
            const SizedBox(height: 14),
            CustomTextField(controller: _aboutController, label: 'Professional Summary', prefixIcon: Icons.edit_note, maxLines: 4),
            const SizedBox(height: 24),

            if (_hasChanges) CustomButton(label: 'Save Changes', onPressed: _saveProfile, isLoading: _isSaving),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}