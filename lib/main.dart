// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'di/injection_container.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized');
  } catch (e) {
    print('❌ Firebase init error: $e');
  }

  // Initialize dependencies
  try {
    await initializeDependencies();
    print('✅ Dependencies initialized');
  } catch (e) {
    print('❌ Dependency init error: $e');
  }


  runApp(const ProviderScope(child: HomeresApp()));
}
