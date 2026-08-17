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
    // Real API call commented out for UI testing:
    // final client = ref.read(paymentsClientProvider);
    // final response = await client.getProviderPayouts(
    //   page: page,
    //   perPage: _perPage,
    //   sortBy: sortBy ?? "created_at",
    //   sortDesc: sortDesc ?? true,
    //   status: status,
    // );
    //
    // if (response.isError || response.data == null) {
    //   throw Exception(response.detail ?? 'Failed to fetch provider payouts');
    // }
    //
    // final items = response.data!.items ?? [];

    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    final allMockItems = [
      Payout(
        id: 'payout_1',
        providerId: 'prov_101',
        customerId: 'cust_201',
        taskId: 'task_301',
        payoutAmount: 250.00,
        customerPaymentAmount: 280.00,
        status: 'completed',
        description: 'Plumbing Repair & Pipe Inspection',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_1',
        urlGeneratedAt: now.subtract(const Duration(days: 1)),
        reference: 'PYT-2026-0891',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        task: TaskLite(
          id: 'task_301',
          title: 'Plumbing Repair & Pipe Inspection',
          description: 'Fixed leaking pipe in master bathroom',
          customerTotalPrice: 280.00,
          platformFee: 30.00,
          providerPayout: 250.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_2',
        providerId: 'prov_101',
        customerId: 'cust_202',
        taskId: 'task_302',
        payoutAmount: 180.50,
        customerPaymentAmount: 200.00,
        status: 'completed',
        description: 'Electrical Socket Wiring',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_2',
        urlGeneratedAt: now.subtract(const Duration(days: 2)),
        reference: 'PYT-2026-0892',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        task: TaskLite(
          id: 'task_302',
          title: 'Electrical Socket Wiring',
          description: 'Installed 3 new wall power sockets',
          customerTotalPrice: 200.00,
          platformFee: 19.50,
          providerPayout: 180.50,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_3',
        providerId: 'prov_101',
        customerId: 'cust_203',
        taskId: 'task_303',
        payoutAmount: 420.00,
        customerPaymentAmount: 460.00,
        status: 'pending',
        description: 'Deep Home Cleaning & Sanitation',
        paymentUrl: null,
        urlGeneratedAt: null,
        reference: 'PYT-2026-0893',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
        task: TaskLite(
          id: 'task_303',
          title: 'Deep Home Cleaning & Sanitation',
          description: 'Full house deep cleaning',
          customerTotalPrice: 460.00,
          platformFee: 40.00,
          providerPayout: 420.00,
          status: 'in_progress',
        ),
      ),
      Payout(
        id: 'payout_4',
        providerId: 'prov_101',
        customerId: 'cust_204',
        taskId: 'task_304',
        payoutAmount: 95.00,
        customerPaymentAmount: 110.00,
        status: 'processing',
        description: 'Lawn Mowing & Gardening',
        paymentUrl: null,
        urlGeneratedAt: null,
        reference: 'PYT-2026-0894',
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        task: TaskLite(
          id: 'task_304',
          title: 'Lawn Mowing & Gardening',
          description: 'Mowed front lawn and trimmed hedges',
          customerTotalPrice: 110.00,
          platformFee: 15.00,
          providerPayout: 95.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_5',
        providerId: 'prov_101',
        customerId: 'cust_205',
        taskId: 'task_305',
        payoutAmount: 310.00,
        customerPaymentAmount: 350.00,
        status: 'completed',
        description: 'AC Maintenance & Gas Refill',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_5',
        urlGeneratedAt: now.subtract(const Duration(days: 4)),
        reference: 'PYT-2026-0895',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
        task: TaskLite(
          id: 'task_305',
          title: 'AC Maintenance & Gas Refill',
          description: 'Serviced split AC unit in living room',
          customerTotalPrice: 350.00,
          platformFee: 40.00,
          providerPayout: 310.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_6',
        providerId: 'prov_101',
        customerId: 'cust_206',
        taskId: 'task_306',
        payoutAmount: 150.00,
        customerPaymentAmount: 165.00,
        status: 'failed',
        description: 'Furniture Assembly (IKEA)',
        paymentUrl: null,
        urlGeneratedAt: null,
        reference: 'PYT-2026-0896',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
        task: TaskLite(
          id: 'task_306',
          title: 'Furniture Assembly (IKEA)',
          description: 'Assembled dining table and 4 chairs',
          customerTotalPrice: 165.00,
          platformFee: 15.00,
          providerPayout: 150.00,
          status: 'cancelled',
        ),
      ),
      Payout(
        id: 'payout_7',
        providerId: 'prov_101',
        customerId: 'cust_207',
        taskId: 'task_307',
        payoutAmount: 500.00,
        customerPaymentAmount: 550.00,
        status: 'completed',
        description: 'Interior Wall Painting',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_7',
        urlGeneratedAt: now.subtract(const Duration(days: 7)),
        reference: 'PYT-2026-0897',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
        task: TaskLite(
          id: 'task_307',
          title: 'Interior Wall Painting',
          description: 'Painted 2 bedrooms with eggshell finish',
          customerTotalPrice: 550.00,
          platformFee: 50.00,
          providerPayout: 500.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_8',
        providerId: 'prov_101',
        customerId: 'cust_208',
        taskId: 'task_308',
        payoutAmount: 120.00,
        customerPaymentAmount: 135.00,
        status: 'pending',
        description: 'TV Wall Mounting & Cable Hiding',
        paymentUrl: null,
        urlGeneratedAt: null,
        reference: 'PYT-2026-0898',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
        task: TaskLite(
          id: 'task_308',
          title: 'TV Wall Mounting & Cable Hiding',
          description: 'Mounted 65 inch OLED TV on drywall',
          customerTotalPrice: 135.00,
          platformFee: 15.00,
          providerPayout: 120.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_9',
        providerId: 'prov_101',
        customerId: 'cust_209',
        taskId: 'task_309',
        payoutAmount: 210.00,
        customerPaymentAmount: 230.00,
        status: 'completed',
        description: 'Kitchen Sink Drain Unclogging',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_9',
        urlGeneratedAt: now.subtract(const Duration(days: 10)),
        reference: 'PYT-2026-0899',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
        task: TaskLite(
          id: 'task_309',
          title: 'Kitchen Sink Drain Unclogging',
          description: 'Cleared grease blockage in kitchen drain',
          customerTotalPrice: 230.00,
          platformFee: 20.00,
          providerPayout: 210.00,
          status: 'completed',
        ),
      ),
      Payout(
        id: 'payout_10',
        providerId: 'prov_101',
        customerId: 'cust_210',
        taskId: 'task_310',
        payoutAmount: 340.00,
        customerPaymentAmount: 380.00,
        status: 'completed',
        description: 'Carpet & Upholstery Cleaning',
        paymentUrl: 'https://checkout.paystack.com/mock_ref_10',
        urlGeneratedAt: now.subtract(const Duration(days: 12)),
        reference: 'PYT-2026-0900',
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
        task: TaskLite(
          id: 'task_310',
          title: 'Carpet & Upholstery Cleaning',
          description: 'Steam cleaned living room sofa and rug',
          customerTotalPrice: 380.00,
          platformFee: 40.00,
          providerPayout: 340.00,
          status: 'completed',
        ),
      ),
    ];

    final filtered = status == null
        ? allMockItems
        : allMockItems
              .where((p) => p.status?.toLowerCase() == status!.toLowerCase())
              .toList();

    if (page > 1) {
      _hasMore = false;
      return [];
    }

    if (filtered.length < _perPage) {
      _hasMore = false;
    }

    return filtered;
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
