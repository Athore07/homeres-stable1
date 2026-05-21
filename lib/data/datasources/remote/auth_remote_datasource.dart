// lib/data/datasources/auth_remote_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String name, String email, String password, String role);
  Future<void> logout();
  Future<UserEntity> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final userDoc = await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();
      
      if (!userDoc.exists) {
        throw AuthException('User data not found');
      }
      
      final data = userDoc.data()!;
      return UserEntity(
        id: credential.user!.uid,
        email: data['email'] ?? email,
        name: data['name'] ?? '',
        phone: data['phone'],
        role: data['role'] ?? FirebaseConstants.roleHomeowner,
        profileImage: data['profileImage'],
        isVerified: data['isVerified'] ?? false,
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Login failed. Please try again.');
    }
  }

  @override
  Future<UserEntity> register(String name, String email, String password, String role) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = UserEntity(
        id: credential.user!.uid,
        email: email,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );
      
      await firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.id)
          .set({
            'email': email,
            'name': name,
            'role': role,
            'isVerified': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
      
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Registration failed. Please try again.');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) throw AuthException('No user logged in');
    
    final userDoc = await firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(currentUser.uid)
        .get();
    
    if (!userDoc.exists) throw AuthException('User data not found');
    
    final data = userDoc.data()!;
    return UserEntity(
      id: currentUser.uid,
      email: data['email'] ?? currentUser.email ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      role: data['role'] ?? FirebaseConstants.roleHomeowner,
      profileImage: data['profileImage'],
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found': return 'No user found with this email';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'Email is already registered';
      case 'invalid-email': return 'Invalid email address';
      case 'weak-password': return 'Password should be at least 6 characters';
      case 'user-disabled': return 'This account has been disabled';
      case 'too-many-requests': return 'Too many attempts. Please try again later';
      case 'network-request-failed': return 'Network error. Please check your connection';
      default: return 'Authentication failed. Please try again';
    }
  }
}