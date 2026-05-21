// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookingDetailNotifier)
final bookingDetailProvider = BookingDetailNotifierProvider._();

final class BookingDetailNotifierProvider
    extends $NotifierProvider<BookingDetailNotifier, BookingDetailState> {
  BookingDetailNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingDetailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingDetailNotifierHash();

  @$internal
  @override
  BookingDetailNotifier create() => BookingDetailNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingDetailState>(value),
    );
  }
}

String _$bookingDetailNotifierHash() =>
    r'd03797258efb2d5362071d95821f04a5a70e7309';

abstract class _$BookingDetailNotifier extends $Notifier<BookingDetailState> {
  BookingDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookingDetailState, BookingDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookingDetailState, BookingDetailState>,
              BookingDetailState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
