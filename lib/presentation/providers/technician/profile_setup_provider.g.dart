// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_setup_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileSetupNotifier)
final profileSetupProvider = ProfileSetupNotifierProvider._();

final class ProfileSetupNotifierProvider
    extends $NotifierProvider<ProfileSetupNotifier, ProfileSetupState> {
  ProfileSetupNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileSetupProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileSetupNotifierHash();

  @$internal
  @override
  ProfileSetupNotifier create() => ProfileSetupNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileSetupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileSetupState>(value),
    );
  }
}

String _$profileSetupNotifierHash() =>
    r'60a5cabcfd21b2093d2d861f606cff344b4fe752';

abstract class _$ProfileSetupNotifier extends $Notifier<ProfileSetupState> {
  ProfileSetupState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProfileSetupState, ProfileSetupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProfileSetupState, ProfileSetupState>,
              ProfileSetupState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
