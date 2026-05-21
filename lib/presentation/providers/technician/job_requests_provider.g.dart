// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_requests_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(JobRequestsNotifier)
final jobRequestsProvider = JobRequestsNotifierProvider._();

final class JobRequestsNotifierProvider
    extends $NotifierProvider<JobRequestsNotifier, JobRequestsState> {
  JobRequestsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'jobRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$jobRequestsNotifierHash();

  @$internal
  @override
  JobRequestsNotifier create() => JobRequestsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JobRequestsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JobRequestsState>(value),
    );
  }
}

String _$jobRequestsNotifierHash() =>
    r'3151e76e531613c1f7a26a6854393c2de966309f';

abstract class _$JobRequestsNotifier extends $Notifier<JobRequestsState> {
  JobRequestsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<JobRequestsState, JobRequestsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JobRequestsState, JobRequestsState>,
              JobRequestsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
