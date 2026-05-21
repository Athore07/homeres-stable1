// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceListNotifier)
final serviceListProvider = ServiceListNotifierProvider._();

final class ServiceListNotifierProvider
    extends $NotifierProvider<ServiceListNotifier, ServiceListState> {
  ServiceListNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serviceListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serviceListNotifierHash();

  @$internal
  @override
  ServiceListNotifier create() => ServiceListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceListState>(value),
    );
  }
}

String _$serviceListNotifierHash() =>
    r'18ce37a24aed4cc85330ca915f034bd260f4bfaf';

abstract class _$ServiceListNotifier extends $Notifier<ServiceListState> {
  ServiceListState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ServiceListState, ServiceListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServiceListState, ServiceListState>,
              ServiceListState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
