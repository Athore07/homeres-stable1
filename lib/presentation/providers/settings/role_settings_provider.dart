// lib/presentation/providers/settings/role_settings_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { homeowner, technician, admin }

class RoleSettings {
  final UserRole role;
  final bool showProfileSection;
  final bool showPreferencesSection;
  final bool showSecuritySection;
  final bool showSupportSection;
  final bool showAdminSection;
  final bool showTechnicianSection;
  final bool showDangerZone;
  final List<String> hiddenSections;

  const RoleSettings({
    required this.role,
    this.showProfileSection = true,
    this.showPreferencesSection = true,
    this.showSecuritySection = true,
    this.showSupportSection = true,
    this.showAdminSection = false,
    this.showTechnicianSection = false,
    this.showDangerZone = true,
    this.hiddenSections = const [],
  });

  factory RoleSettings.forHomeowner() {
    return const RoleSettings(
      role: UserRole.homeowner,
      showAdminSection: false,
      showTechnicianSection: false,
    );
  }

  factory RoleSettings.forTechnician() {
    return const RoleSettings(
      role: UserRole.technician,
      showAdminSection: false,
      showTechnicianSection: true,
    );
  }

  factory RoleSettings.forAdmin() {
    return const RoleSettings(
      role: UserRole.admin,
      showAdminSection: true,
      showTechnicianSection: false,
      showDangerZone: false,
    );
  }
}

// Provider for role-based settings
final roleSettingsProvider = Provider<RoleSettings>((ref) {
  // This would normally read from auth state to determine role
  // For now, return homeowner as default
  return RoleSettings.forHomeowner();
});