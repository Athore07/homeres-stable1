// lib/presentation/providers/notification/notification_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firebase_service.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());