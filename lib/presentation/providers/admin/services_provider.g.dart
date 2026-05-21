// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'services_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServicesNotifier)
final servicesProvider = ServicesNotifierProvider._();

final class ServicesNotifierProvider
    extends $NotifierProvider<ServicesNotifier, ServicesState> {
  ServicesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'servicesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$servicesNotifierHash();

  @$internal
  @override
  ServicesNotifier create() => ServicesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServicesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServicesState>(value),
    );
  }
}

String _$servicesNotifierHash() => r'3ff4d84aecbba2d399ff24c2f7225c8f7d269e02';

abstract class _$ServicesNotifier extends $Notifier<ServicesState> {
  ServicesState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ServicesState, ServicesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServicesState, ServicesState>,
              ServicesState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
