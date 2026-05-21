// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EarningsNotifier)
final earningsProvider = EarningsNotifierProvider._();

final class EarningsNotifierProvider
    extends $NotifierProvider<EarningsNotifier, EarningsState> {
  EarningsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earningsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earningsNotifierHash();

  @$internal
  @override
  EarningsNotifier create() => EarningsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EarningsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EarningsState>(value),
    );
  }
}

String _$earningsNotifierHash() => r'e3f58d777936a07d5f9cd2e694f97465f7caa8f3';

abstract class _$EarningsNotifier extends $Notifier<EarningsState> {
  EarningsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EarningsState, EarningsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EarningsState, EarningsState>,
              EarningsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
