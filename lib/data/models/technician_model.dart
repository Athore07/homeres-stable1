// lib/data/models/technician_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/technician.dart';

class TechnicianModel extends TechnicianEntity {
  const TechnicianModel({
    required super.id,
    required super.userId,
    required super.skills,
    required super.certifications,
    required super.experience,
    required super.verificationStatus,
    required super.latitude,
    required super.longitude,
    required super.isAvailable,
    super.rating = 0.0,
    super.totalJobs = 0,
    required super.hourlyRate,
    super.profileImage,
    required super.name,
    required super.phone,
    required super.createdAt, 
    required super.email, 
    required super.specialty,
  });

  factory TechnicianModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TechnicianModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      certifications: List<String>.from(data['certifications'] ?? []),
      experience: data['experience'] ?? 0,
      verificationStatus: data['verificationStatus'] ?? 'pending',
      latitude: (data['location'] as GeoPoint?)?.latitude ?? 0.0,
      longitude: (data['location'] as GeoPoint?)?.longitude ?? 0.0,
      isAvailable: data['isAvailable'] ?? false,
      rating: (data['rating'] ?? 0).toDouble(),
      totalJobs: data['totalJobs'] ?? 0,
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      profileImage: data['profileImage'],
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      email: data['email'] ?? '',
      specialty: data['specialty'] ?? '',
    );
  }
}