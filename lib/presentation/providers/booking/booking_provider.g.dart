// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookingNotifier)
final bookingProvider = BookingNotifierProvider._();

final class BookingNotifierProvider
    extends $NotifierProvider<BookingNotifier, BookingState> {
  BookingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingNotifierHash();

  @$internal
  @override
  BookingNotifier create() => BookingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookingState>(value),
    );
  }
}

String _$bookingNotifierHash() => r'b3fd6a5a0bea09bf97a9c188c52a96aa84b3b3ce';

abstract class _$BookingNotifier extends $Notifier<BookingState> {
  BookingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookingState, BookingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookingState, BookingState>,
              BookingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(pendingBookings)
final pendingBookingsProvider = PendingBookingsProvider._();

final class PendingBookingsProvider
    extends
        $FunctionalProvider<
          List<BookingEntity>,
          List<BookingEntity>,
          List<BookingEntity>
        >
    with $Provider<List<BookingEntity>> {
  PendingBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingBookingsHash();

  @$internal
  @override
  $ProviderElement<List<BookingEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<BookingEntity> create(Ref ref) {
    return pendingBookings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BookingEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BookingEntity>>(value),
    );
  }
}

String _$pendingBookingsHash() => r'7f1dbcb8117fbb146742ba07d43a2b0ebfdefc2e';

@ProviderFor(activeBookings)
final activeBookingsProvider = ActiveBookingsProvider._();

final class ActiveBookingsProvider
    extends
        $FunctionalProvider<
          List<BookingEntity>,
          List<BookingEntity>,
          List<BookingEntity>
        >
    with $Provider<List<BookingEntity>> {
  ActiveBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeBookingsHash();

  @$internal
  @override
  $ProviderElement<List<BookingEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<BookingEntity> create(Ref ref) {
    return activeBookings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BookingEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BookingEntity>>(value),
    );
  }
}

String _$activeBookingsHash() => r'578e0d353cac3fced8b2676c5b0c9cccdc6f3b2e';

@ProviderFor(completedBookings)
final completedBookingsProvider = CompletedBookingsProvider._();

final class CompletedBookingsProvider
    extends
        $FunctionalProvider<
          List<BookingEntity>,
          List<BookingEntity>,
          List<BookingEntity>
        >
    with $Provider<List<BookingEntity>> {
  CompletedBookingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedBookingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedBookingsHash();

  @$internal
  @override
  $ProviderElement<List<BookingEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<BookingEntity> create(Ref ref) {
    return completedBookings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BookingEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BookingEntity>>(value),
    );
  }
}

String _$completedBookingsHash() => r'9556429630c46af4d3a5c260caac7deb20a566f5';

@ProviderFor(pendingBookingsCount)
final pendingBookingsCountProvider = PendingBookingsCountProvider._();

final class PendingBookingsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  PendingBookingsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingBookingsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingBookingsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return pendingBookingsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$pendingBookingsCountHash() =>
    r'32d9fef6670b9adafec0cd462c6202c4a7b111d2';

@ProviderFor(activeBookingsCount)
final activeBookingsCountProvider = ActiveBookingsCountProvider._();

final class ActiveBookingsCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  ActiveBookingsCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeBookingsCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeBookingsCountHash();

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    return activeBookingsCount(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$activeBookingsCountHash() =>
    r'fe1776d9358d9e3bc727d589e9b632b49a93c41f';
