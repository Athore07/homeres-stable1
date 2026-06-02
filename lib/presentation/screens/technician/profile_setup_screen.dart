// lib/presentation/screens/technician/profile_setup_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/technician/profile_setup_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/common/section_header.dart';
import '../../../routing/route_names.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        final notifier = ref.read(profileSetupProvider.notifier);
        notifier.loadProfile(user.id);
        notifier.startListening(user.id);
      }
    });
  }

  @override
  void dispose() {
    ref.read(profileSetupProvider.notifier).stopListening();
    _specialtyController.dispose();
    _experienceController.dispose();
    _hourlyRateController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ProfileSetupNotifier notifier) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (image != null) notifier.setImagePath(image.path);
  }

  void _showImagePicker(ProfileSetupNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        final state = ref.read(profileSetupProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Text('Profile Photo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: GestureDetector(onTap: () { Navigator.pop(context); _pickImage(notifier); }, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.2))), child: const Column(children: [Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 32), SizedBox(height: 8), Text('Camera', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))])))),
                const SizedBox(width: 16),
                Expanded(child: GestureDetector(onTap: () { Navigator.pop(context); _pickImage(notifier); }, child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.accent.withOpacity(0.2))), child: const Column(children: [Icon(Icons.photo_library_rounded, color: AppColors.accent, size: 32), SizedBox(height: 8), Text('Gallery', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))])))),
              ]),
              if (state.imagePath != null || state.existingImageUrl != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(onPressed: () { Navigator.pop(context); notifier.setImagePath(null); }, icon: const Icon(Icons.delete_outline, color: AppColors.error), label: const Text('Remove Photo', style: TextStyle(color: AppColors.error))),
              ],
            ]),
          ),
        );
      },
    );
  }

  Future<void> _submitProfile(ProfileSetupNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authProvider).user;
    if (user == null) { context.showSnackBar('Please login first'); return; }

    final success = await notifier.submitProfile(user.id, user.name, user.email, user.phone ?? '');

    if (mounted) {
      if (success) {
        context.showSnackBar('Profile submitted for verification!');
        context.go(RouteNames.technicianHome);
      } else {
        context.showSnackBar('Failed to submit profile. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);

    // Update text controllers when profile data loads
    if (state.profileExists && state.specialty.isNotEmpty) {
      if (_specialtyController.text != state.specialty) {
        _specialtyController.text = state.specialty;
      }
      if (_experienceController.text != state.experience) {
        _experienceController.text = state.experience;
      }
      if (_hourlyRateController.text != state.hourlyRate) {
        _hourlyRateController.text = state.hourlyRate;
      }
      if (_aboutController.text != state.about) {
        _aboutController.text = state.about;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Setup', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => context.go(RouteNames.technicianHome), child: const Text('Skip for now', style: TextStyle(color: AppColors.textHint, fontSize: 12))),
        ],
      ),
      body: state.isSuccess
          ? _SuccessView(onDone: () => context.go(RouteNames.technicianHome))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Verification Status Banner
                  if (state.profileExists) _VerificationStatus(state: state),
                  
                  const SizedBox(height: 8),

                  // Profile Photo
                  _ProfilePhoto(
                    imagePath: state.imagePath,
                    existingUrl: state.existingImageUrl,
                    onTap: () => _showImagePicker(notifier),
                  ),
                  const SizedBox(height: 28),

                  // Professional Info
                  SectionHeader(title: 'Professional Information', accentColor: AppColors.primary),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _specialtyController, label: 'Specialty', hint: 'e.g., Electrician, Plumber', prefixIcon: Icons.engineering_rounded, onChanged: notifier.setSpecialty, validator: (v) => v?.isEmpty == true ? 'Specialty is required' : null),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: CustomTextField(controller: _experienceController, label: 'Experience (Years)', hint: 'e.g., 5', prefixIcon: Icons.work_history_rounded, keyboardType: TextInputType.number, onChanged: notifier.setExperience, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(controller: _hourlyRateController, label: 'Hourly Rate (\$)', hint: 'e.g., 50', prefixIcon: Icons.attach_money_rounded, keyboardType: TextInputType.number, onChanged: notifier.setHourlyRate, validator: (v) => v?.isEmpty == true ? 'Required' : null)),
                  ]),
                  const SizedBox(height: 24),

// Skills
                   SectionHeader(title: 'Skills & Expertise', accentColor: AppColors.success),
                   const SizedBox(height: 12),
                   Wrap(spacing: 12, runSpacing: 12, children: ProfileSetupState.availableSkills.map((skill) => GestureDetector(
                     onTap: () => notifier.toggleSkill(skill),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       decoration: BoxDecoration(
                         color: state.skills.contains(skill) ? AppColors.success.withOpacity(0.15) : Colors.grey[200],
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: state.skills.contains(skill) ? AppColors.success : Colors.grey[300]!),
                       ),
                       child: Text(skill, style: TextStyle(color: state.skills.contains(skill) ? AppColors.success : Colors.grey[600], fontSize: 12)),
                     ),
                   )).toList()),
                   const SizedBox(height: 24),

                  // Certifications
                  SectionHeader(title: 'Certifications & Documents', accentColor: AppColors.info),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.info.withOpacity(0.3), width: 1.5)),
                    child: const Column(children: [
                      Icon(Icons.cloud_upload_rounded, size: 36, color: AppColors.info), SizedBox(height: 8),
                      Text('Upload Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 4),
                      Text('Upload your licenses, certificates, or any relevant documents.', style: TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center), SizedBox(height: 4),
                      Text('Supported: PDF, JPG, PNG', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ]),
                  ),
                  const SizedBox(height: 24),

                  // About
                  SectionHeader(title: 'About You', accentColor: AppColors.accent),
                  const SizedBox(height: 12),
                  CustomTextField(controller: _aboutController, label: 'Professional Summary', hint: 'Tell customers about your experience and expertise.', maxLines: 4, prefixIcon: Icons.edit_note_rounded, onChanged: notifier.setAbout),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    label: state.profileExists ? 'Update Profile' : 'Submit Profile for Verification',
                    icon: Icons.check_circle_rounded,
                    onPressed: state.isSubmitting ? null : () => _submitProfile(notifier),
                    isLoading: state.isSubmitting,
                  ),
                  const SizedBox(height: 12),
                  Text('Your profile will be reviewed by our team. You\'ll be notified once verified.', style: TextStyle(color: Colors.grey[400], fontSize: 11), textAlign: TextAlign.center),
                  if (state.error != null) ...[const SizedBox(height: 12), _ErrorBanner(message: state.error!)],
                  const SizedBox(height: 32),
                ]),
              ),
            ),
    );
  }
}

// Verification Status Banner
class _VerificationStatus extends StatelessWidget {
  final ProfileSetupState state;
  const _VerificationStatus({required this.state});

  @override
  Widget build(BuildContext context) {
    final isVerified = state.isVerified;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isVerified ? AppColors.success.withOpacity(0.08) : AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isVerified ? AppColors.success.withOpacity(0.2) : AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(children: [
        Icon(isVerified ? Icons.verified_rounded : Icons.pending_rounded, color: isVerified ? AppColors.success : AppColors.warning, size: 22),
        const SizedBox(width: 10),
        Expanded(child: Text(isVerified ? 'Your profile is verified! You can now receive job requests.' : 'Your profile is pending verification. We\'ll notify you once approved.', style: TextStyle(color: isVerified ? AppColors.success : AppColors.warning, fontSize: 12, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

// Profile Photo Widget
class _ProfilePhoto extends StatelessWidget {
  final String? imagePath;
  final String? existingUrl;
  final VoidCallback onTap;
  const _ProfilePhoto({this.imagePath, this.existingUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 3),
              image: imagePath != null
                  ? DecorationImage(image: FileImage(File(imagePath!)), fit: BoxFit.cover)
                  : existingUrl != null
                      ? DecorationImage(image: NetworkImage(existingUrl!), fit: BoxFit.cover)
                      : null,
            ),
            child: imagePath == null && existingUrl == null
                ? Container(decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, size: 36, color: AppColors.primary))
                : null,
          ),
          Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(7), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 16))),
        ]),
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut),
    );
  }
}

// Success View
class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 80), const SizedBox(height: 24),
      Text('Profile Submitted!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Text('Your profile has been submitted for verification.\nYou\'ll be notified once approved.', style: TextStyle(color: Colors.grey[500], fontSize: 14), textAlign: TextAlign.center), const SizedBox(height: 32),
      CustomButton(label: 'Go to Dashboard', onPressed: onDone),
    ])));
  }
}

// Error Banner
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.08), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.error_outline, color: AppColors.error, size: 16), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 12)))]));
  }
}