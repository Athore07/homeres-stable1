// lib/domain/entities/technician.dart
class TechnicianEntity {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String specialty;
  final List<String> skills;
  final List<String> certifications;
  final int experience;
  final double hourlyRate;
  final double rating;
  final int totalJobs;
  final bool isAvailable;
  final String verificationStatus;
  final double latitude;
  final double longitude;
  final String? profileImage;
  final DateTime createdAt;

  const TechnicianEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialty,
    required this.skills,
    required this.certifications,
    required this.experience,
    required this.hourlyRate,
    required this.rating,
    required this.totalJobs,
    required this.isAvailable,
    required this.verificationStatus,
    required this.latitude,
    required this.longitude,
    this.profileImage,
    required this.createdAt,
  });

  bool get isVerified => verificationStatus == 'verified';
  bool get isPending => verificationStatus == 'pending';
  bool get isRejected => verificationStatus == 'rejected';

  TechnicianEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? specialty,
    List<String>? skills,
    List<String>? certifications,
    int? experience,
    double? hourlyRate,
    double? rating,
    int? totalJobs,
    bool? isAvailable,
    String? verificationStatus,
    double? latitude,
    double? longitude,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return TechnicianEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      experience: experience ?? this.experience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      isAvailable: isAvailable ?? this.isAvailable,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}