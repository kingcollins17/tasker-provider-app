import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';

typedef EarningsDateRangeParam = ({String? startDate, String? endDate})?;

/// Enum representing supported time durations for provider earnings filtering.
enum EarningsDuration {
  today,
  past1Week,
  past1Month,
  past3Months,
  past6Months;

  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case EarningsDuration.today:
        return "Today's Earnings";
      case EarningsDuration.past1Week:
        return "Past 1 Week";
      case EarningsDuration.past1Month:
        return "Past 1 Month";
      case EarningsDuration.past3Months:
        return "Past 3 Months";
      case EarningsDuration.past6Months:
        return "Past 6 Months";
    }
  }

  /// Description explaining the date range.
  String get description {
    switch (this) {
      case EarningsDuration.today:
        return "Earnings accumulated today";
      case EarningsDuration.past1Week:
        return "Earnings for the last 7 days";
      case EarningsDuration.past1Month:
        return "Earnings for the last 30 days";
      case EarningsDuration.past3Months:
        return "Earnings for the last 90 days";
      case EarningsDuration.past6Months:
        return "Earnings for the last 180 days";
    }
  }

  /// Subtitle for display on the earnings card.
  String get cardSubtitle {
    switch (this) {
      case EarningsDuration.today:
        return "Total earnings for today";
      case EarningsDuration.past1Week:
        return "Total earnings past 7 days";
      case EarningsDuration.past1Month:
        return "Total earnings past 30 days";
      case EarningsDuration.past3Months:
        return "Total earnings past 90 days";
      case EarningsDuration.past6Months:
        return "Total earnings past 180 days";
    }
  }

  /// Calculates the start date for the duration based on current time.
  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case EarningsDuration.today:
        return DateTime(now.year, now.month, now.day);
      case EarningsDuration.past1Week:
        return now.subtract(const Duration(days: 7));
      case EarningsDuration.past1Month:
        return DateTime(now.year, now.month - 1, now.day);
      case EarningsDuration.past3Months:
        return DateTime(now.year, now.month - 3, now.day);
      case EarningsDuration.past6Months:
        return DateTime(now.year, now.month - 6, now.day);
    }
  }

  /// ISO 8601 formatted start date string.
  String get startDateIso => startDate.toIso8601String();
}

/// Future family provider for fetching earnings stats for a given date range.
final providerEarningsStatsProvider =
    FutureProvider.family<Earnings, EarningsDateRangeParam?>((
      ref,
      dateRange,
    ) async {
      final client = ref.watch(paymentsClientProvider);
      final response = await client.getProviderEarningsStats(
        startDate: dateRange?.startDate,
        endDate: dateRange?.endDate,
      );
      if (response.isError || response.data == null) {
        throw Exception(
          response.detail ?? 'Failed to fetch provider earning stats',
        );
      }
      return response.data!;
    }, retry: (_, __) => null);

/// Notifier to manage the currently selected earnings duration.
class EarningsDurationNotifier extends Notifier<EarningsDuration> {
  @override
  EarningsDuration build() => EarningsDuration.today;

  void setDuration(EarningsDuration duration) {
    state = duration;
  }
}

/// Provider exposing the [EarningsDurationNotifier] state.
final earningsDurationProvider =
    NotifierProvider<EarningsDurationNotifier, EarningsDuration>(
      EarningsDurationNotifier.new,
    );

String get _tomorrow1201AMIso {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1, 0, 1).toIso8601String();
}

/// Dynamic provider that watches [earningsDurationProvider] and fetches stats based on the selected duration.
final selectedEarningsProvider = FutureProvider<Earnings>((ref) {
  final duration = ref.watch(earningsDurationProvider);
  final earnings = ref.watch(
    providerEarningsStatsProvider((
      startDate: duration.startDateIso,
      endDate: _tomorrow1201AMIso,
    )).future,
  );
  return earnings;
});

/// Derived provider for today's earnings.
final todayEarningsProvider = Provider<AsyncValue<Earnings?>>((ref) {
  return ref.watch(
    providerEarningsStatsProvider((
      startDate: EarningsDuration.today.startDateIso,
      endDate: _tomorrow1201AMIso,
    )),
  );
});

/// Derived provider for past 1 week earnings.
final past1WeekEarningsProvider = Provider<AsyncValue<Earnings?>>((ref) {
  return ref.watch(
    providerEarningsStatsProvider((
      startDate: EarningsDuration.past1Week.startDateIso,
      endDate: _tomorrow1201AMIso,
    )),
  );
});

/// Derived provider for past 1 month earnings.
final past1MonthEarningsProvider = Provider<AsyncValue<Earnings?>>((ref) {
  return ref.watch(
    providerEarningsStatsProvider((
      startDate: EarningsDuration.past1Month.startDateIso,
      endDate: _tomorrow1201AMIso,
    )),
  );
});

/// Derived provider for past 3 months earnings.
final past3MonthsEarningsProvider = Provider<AsyncValue<Earnings?>>((ref) {
  return ref.watch(
    providerEarningsStatsProvider((
      startDate: EarningsDuration.past3Months.startDateIso,
      endDate: _tomorrow1201AMIso,
    )),
  );
});

/// Derived provider for past 6 months earnings.
final past6MonthsEarningsProvider = Provider<AsyncValue<Earnings?>>((ref) {
  return ref.watch(
    providerEarningsStatsProvider((
      startDate: EarningsDuration.past6Months.startDateIso,
      endDate: _tomorrow1201AMIso,
    )),
  );
});

/// Notifier to manage paginated list of provider payouts.
class ProviderPayoutsNotifier extends AsyncNotifier<List<Payout>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? status;
  final String? sortBy;
  final bool? sortDesc;

  ProviderPayoutsNotifier({this.status, this.sortBy, this.sortDesc});

  bool get hasMore => _hasMore;
  int get currentPage => _page;
  int get perPage => _perPage;

  @override
  Future<List<Payout>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPage(1);
  }

  Future<List<Payout>> _fetchPage(int page) async {
    final client = ref.read(paymentsClientProvider);
    final response = await client.getProviderPayouts(
      page: page,
      perPage: _perPage,
      sortBy: sortBy ?? "created_at",
      sortDesc: sortDesc ?? true,
      status: status,
    );

    if (response.isError || response.data == null) {
      throw Exception(response.detail ?? 'Failed to fetch provider payouts');
    }

    final items = response.data!.items ?? [];

    if (items.length < _perPage) {
      _hasMore = false;
    }

    return items;
  }

  /// Refreshes the payouts list by re-initializing build().
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  /// Loads the next page of payouts and appends them to current state.
  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentItems = state.value ?? [];
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      _page++;
      final nextItems = await _fetchPage(_page);
      return [...currentItems, ...nextItems];
    });
  }
}

/// Provider exposing provider payouts list filtered by status.
final providerPayoutsProvider =
    AsyncNotifierProvider.family<
      ProviderPayoutsNotifier,
      List<Payout>,
      String?
    >((status) => ProviderPayoutsNotifier(status: status));

/// FutureProvider for fetching the provider's current outstanding commission debt summary.
final debtSummaryProvider = FutureProvider<Debt>((ref) async {
  final client = ref.watch(paymentsClientProvider);
  final response = await client.getDebtSummary();
  if (response.isError || response.data == null) {
    throw Exception(
      response.detail ?? 'Failed to fetch debt summary',
    );
  }
  return response.data!;
}, retry: (_, __) => null);

