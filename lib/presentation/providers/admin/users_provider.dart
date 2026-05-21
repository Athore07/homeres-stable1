// lib/presentation/providers/admin/users_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/firebase_service.dart';

part 'users_provider.g.dart';

class UsersState {
  final List<Map<String, dynamic>> users;
  final String selectedRole;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final int totalUsers;
  final int activeUsers;
  final int suspendedUsers;

  const UsersState({
    this.users = const [],
    this.selectedRole = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.suspendedUsers = 0,
  });

  List<Map<String, dynamic>> get filteredUsers {
    return users.where((user) {
      if (selectedRole != 'All' && user['role'] != selectedRole.toLowerCase()) return false;
      if (searchQuery.isNotEmpty) {
        final name = (user['name'] as String).toLowerCase();
        final email = (user['email'] as String).toLowerCase();
        if (!name.contains(searchQuery) && !email.contains(searchQuery)) return false;
      }
      return true;
    }).toList();
  }

  UsersState copyWith({
    List<Map<String, dynamic>>? users,
    String? selectedRole,
    String? searchQuery,
    bool? isLoading,
    String? error,
    int? totalUsers,
    int? activeUsers,
    int? suspendedUsers,
  }) {
    return UsersState(
      users: users ?? this.users,
      selectedRole: selectedRole ?? this.selectedRole,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalUsers: totalUsers ?? this.totalUsers,
      activeUsers: activeUsers ?? this.activeUsers,
      suspendedUsers: suspendedUsers ?? this.suspendedUsers,
    );
  }
}

@riverpod
class UsersNotifier extends _$UsersNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  UsersState build() {
    loadUsers();
    return const UsersState();
  }

  void setRole(String role) {
    state = state.copyWith(selectedRole: role);
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query.toLowerCase());
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final snapshot = await _firebaseService.usersRef.orderBy('createdAt', descending: true).get();

      final users = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        int bookingCount = 0;
        try {
          final bs = await _firebaseService.bookingsRef.where('homeownerId', isEqualTo: doc.id).count().get();
          bookingCount = bs.count!;
        } catch (_) {}

        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'email': data['email'] ?? '',
          'phone': data['phone'] ?? '',
          'role': data['role'] ?? 'homeowner',
          'status': data['status'] ?? 'active',
          'isVerified': data['isVerified'] ?? false,
          'profileImage': data['profileImage'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'lastLogin': (data['lastLogin'] as Timestamp?)?.toDate(),
          'bookings': bookingCount,
        };
      }).toList());

      state = state.copyWith(
        users: users,
        totalUsers: users.length,
        activeUsers: users.where((u) => u['status'] == 'active').length,
        suspendedUsers: users.where((u) => u['status'] == 'suspended').length,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> suspendUser(String userId) async {
    try {
      await _firebaseService.usersRef.doc(userId).update({'status': 'suspended', 'suspendedAt': FieldValue.serverTimestamp()});
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to suspend user');
    }
  }

  Future<void> activateUser(String userId) async {
    try {
      await _firebaseService.usersRef.doc(userId).update({'status': 'active'});
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to activate user');
    }
  }

  Future<void> changeRole(String userId, String currentRole) async {
    final newRole = currentRole == 'homeowner' ? 'technician' : 'homeowner';
    try {
      await _firebaseService.usersRef.doc(userId).update({'role': newRole});
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to change role');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firebaseService.usersRef.doc(userId).delete();
      await loadUsers();
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete user');
    }
  }
}