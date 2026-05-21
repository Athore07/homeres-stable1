// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constants/firebase_constants.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  User? get currentUser => auth.currentUser;
  Stream<User?> get authStateChanges => auth.authStateChanges();

  CollectionReference get usersRef => 
      firestore.collection(FirebaseConstants.usersCollection);
  
  CollectionReference get techniciansRef => 
      firestore.collection(FirebaseConstants.techniciansCollection);
  
  CollectionReference get servicesRef => 
      firestore.collection(FirebaseConstants.servicesCollection);
  
  CollectionReference get bookingsRef => 
      firestore.collection(FirebaseConstants.bookingsCollection);
  
  CollectionReference get reviewsRef => 
      firestore.collection(FirebaseConstants.reviewsCollection);
  
  CollectionReference get notificationsRef => 
      firestore.collection(FirebaseConstants.notificationsCollection);
  
  CollectionReference get chatsRef => 
      firestore.collection(FirebaseConstants.chatsCollection);

  Reference get storageRef => storage.ref();
  
  Reference userImageRef(String userId) => 
      storage.ref().child('users/$userId/profile.jpg');
}