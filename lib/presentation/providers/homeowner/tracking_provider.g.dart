// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TrackingNotifier)
final trackingProvider = TrackingNotifierProvider._();

final class TrackingNotifierProvider
    extends $NotifierProvider<TrackingNotifier, TrackingState> {
  TrackingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingNotifierHash();

  @$internal
  @override
  TrackingNotifier create() => TrackingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrackingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrackingState>(value),
    );
  }
}

String _$trackingNotifierHash() => r'5d948ec8f4a38e2696d46c7fe92aefcb2dd61001';

abstract class _$TrackingNotifier extends $Notifier<TrackingState> {
  TrackingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TrackingState, TrackingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TrackingState, TrackingState>,
              TrackingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
