// lib/presentation/providers/technician/profile_setup_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import 'dart:async';
import '../../../core/services/firebase_service.dart';

part 'profile_setup_provider.g.dart';

class ProfileSetupState {
  final String specialty;
  final String experience;
  final String hourlyRate;
  final String about;
  final List<String> skills;
  final String? imagePath;
  final String? existingImageUrl;
  final bool isSubmitting;
  final bool isSuccess;
  final bool profileExists;
  final String verificationStatus;
  final String? error;

  const ProfileSetupState({
    this.specialty = '',
    this.experience = '',
    this.hourlyRate = '',
    this.about = '',
    this.skills = const [],
    this.imagePath,
    this.existingImageUrl,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.profileExists = false,
    this.verificationStatus = 'pending',
    this.error,
  });

  static const availableSkills = [
    'Wiring', 'Circuit Breaker', 'Panel Repair', 'Outlet Installation',
    'Pipe Repair', 'Drain Cleaning', 'Fixture Installation',
    'Fridge Repair', 'Washer Repair', 'Dryer Repair',
    'AC Installation', 'AC Maintenance', 'Heating Repair',
  ];

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';

  ProfileSetupState copyWith({
    String? specialty, String? experience, String? hourlyRate, String? about,
    List<String>? skills, String? imagePath, String? existingImageUrl,
    bool? isSubmitting, bool? isSuccess, bool? profileExists,
    String? verificationStatus, String? error,
  }) {
    return ProfileSetupState(
      specialty: specialty ?? this.specialty, experience: experience ?? this.experience,
      hourlyRate: hourlyRate ?? this.hourlyRate, about: about ?? this.about,
      skills: skills ?? this.skills, imagePath: imagePath ?? this.imagePath,
      existingImageUrl: existingImageUrl ?? this.existingImageUrl,
      isSubmitting: isSubmitting ?? this.isSubmitting, isSuccess: isSuccess ?? this.isSuccess,
      profileExists: profileExists ?? this.profileExists,
      verificationStatus: verificationStatus ?? this.verificationStatus, error: error,
    );
  }
}

@riverpod
class ProfileSetupNotifier extends _$ProfileSetupNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _subscription;

  @override
  ProfileSetupState build() => const ProfileSetupState();

  // Start listening for profile changes
  void startListening(String technicianId) {
    _subscription?.cancel();
    
    _subscription = _firebaseService.techniciansRef
        .doc(technicianId)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              state = state.copyWith(
                profileExists: true,
                specialty: data['specialty'] as String? ?? state.specialty,
                experience: (data['experience'] as num?)?.toString() ?? state.experience,
                hourlyRate: (data['hourlyRate'] as num?)?.toString() ?? state.hourlyRate,
                about: data['about'] as String? ?? state.about,
                skills: data['skills'] != null ? List<String>.from(data['skills']) : state.skills,
                existingImageUrl: data['profileImage'] as String?,
                verificationStatus: data['verificationStatus'] as String? ?? 'pending',
              );
            }
          },
          onError: (e) => state = state.copyWith(error: e.toString()),
        );
  }

  // Stop listener
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Load existing profile data
  Future<void> loadProfile(String technicianId) async {
    try {
      final doc = await _firebaseService.techniciansRef.doc(technicianId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        state = state.copyWith(
          profileExists: true,
          specialty: data['specialty'] as String? ?? '',
          experience: (data['experience'] as num?)?.toString() ?? '',
          hourlyRate: (data['hourlyRate'] as num?)?.toString() ?? '',
          about: data['about'] as String? ?? '',
          skills: data['skills'] != null ? List<String>.from(data['skills']) : [],
          existingImageUrl: data['profileImage'] as String?,
          verificationStatus: data['verificationStatus'] as String? ?? 'pending',
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setSpecialty(String v) => state = state.copyWith(specialty: v);
  void setExperience(String v) => state = state.copyWith(experience: v);
  void setHourlyRate(String v) => state = state.copyWith(hourlyRate: v);
  void setAbout(String v) => state = state.copyWith(about: v);
  void setImagePath(String? path) => state = state.copyWith(imagePath: path);

  void toggleSkill(String skill) {
    final list = List<String>.from(state.skills);
    list.contains(skill) ? list.remove(skill) : list.add(skill);
    state = state.copyWith(skills: list);
  }

  Future<bool> submitProfile(String userId, String userName, String email, String phone) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      String? imageUrl = state.existingImageUrl;
      
      // Upload new image if selected
      if (state.imagePath != null) {
        final ref = _firebaseService.storageRef.child('technicians/$userId/profile.jpg');
        await ref.putFile(File(state.imagePath!));
        imageUrl = await ref.getDownloadURL();
      }

      await _firebaseService.techniciansRef.doc(userId).set({
        'userId': userId,
        'name': userName,
        'email': email,
        'phone': phone,
        'specialty': state.specialty,
        'experience': int.tryParse(state.experience) ?? 0,
        'hourlyRate': double.tryParse(state.hourlyRate) ?? 0.0,
        'about': state.about,
        'skills': state.skills,
        'profileImage': imageUrl,
        'verificationStatus': 'pending',
        'isAvailable': false,
        'rating': 0.0,
        'totalJobs': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Use merge to preserve existing fields

      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
  }
}