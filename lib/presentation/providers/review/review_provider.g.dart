// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReviewNotifier)
final reviewProvider = ReviewNotifierProvider._();

final class ReviewNotifierProvider
    extends $NotifierProvider<ReviewNotifier, ReviewState> {
  ReviewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewNotifierHash();

  @$internal
  @override
  ReviewNotifier create() => ReviewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewState>(value),
    );
  }
}

String _$reviewNotifierHash() => r'ae47dd5ea626f1bae81bc107c87b90c8e23cf59a';

abstract class _$ReviewNotifier extends $Notifier<ReviewState> {
  ReviewState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ReviewState, ReviewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReviewState, ReviewState>,
              ReviewState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
