// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookingHistoryNotifier)
final bookingHistoryProvider = BookingHistoryNotifierProvider._();

final class BookingHistoryNotifierProvider
    extends $NotifierProvider<BookingHistoryNotifier, BookingHistoryState> {
  BookingHistoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingHistoryNotifierHash();

  @$internal
  @override
  BookingHistoryNotifier create() => BookingHistoryNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingHistoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingHistoryState>(value),
    );
  }
}

String _$bookingHistoryNotifierHash() =>
    r'192b406eddd3920eb058412a3ed7be7f6acca0a2';

abstract class _$BookingHistoryNotifier extends $Notifier<BookingHistoryState> {
  BookingHistoryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookingHistoryState, BookingHistoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookingHistoryState, BookingHistoryState>,
              BookingHistoryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
