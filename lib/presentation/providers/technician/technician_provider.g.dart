// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TechnicianNotifier)
final technicianProvider = TechnicianNotifierProvider._();

final class TechnicianNotifierProvider
    extends $NotifierProvider<TechnicianNotifier, TechnicianState> {
  TechnicianNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'technicianProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$technicianNotifierHash();

  @$internal
  @override
  TechnicianNotifier create() => TechnicianNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TechnicianState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TechnicianState>(value),
    );
  }
}

String _$technicianNotifierHash() =>
    r'980ddf14301587414ccffcfecb6c9761d04ff926';

abstract class _$TechnicianNotifier extends $Notifier<TechnicianState> {
  TechnicianState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TechnicianState, TechnicianState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TechnicianState, TechnicianState>,
              TechnicianState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
