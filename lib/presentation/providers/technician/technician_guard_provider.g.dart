// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'technician_guard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TechnicianGuard)
final technicianGuardProvider = TechnicianGuardProvider._();

final class TechnicianGuardProvider
    extends $AsyncNotifierProvider<TechnicianGuard, bool> {
  TechnicianGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'technicianGuardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$technicianGuardHash();

  @$internal
  @override
  TechnicianGuard create() => TechnicianGuard();
}

String _$technicianGuardHash() => r'afa35602a5e00757c07d68ee8b4e540c5d35a4ee';

abstract class _$TechnicianGuard extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
