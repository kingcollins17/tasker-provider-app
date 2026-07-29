import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'payments_client.g.dart';

@RestApi(baseUrl: "/api/v1/")
abstract class PaymentsClient {
  factory PaymentsClient(Dio dio, {String baseUrl}) = _PaymentsClient;

  @GET("payments/stats/provider/earnings")
  Future<BaseApiResponse<Earnings>> getProviderEarningsStats({
    @Query("start_date") String? startDate,
    @Query("end_date") String? endDate,
  });

  @GET("payments/provider/payouts")
  Future<BaseApiResponse<PaginatedData<Payout>>> getProviderPayouts({
    @Query("page") int? page,
    @Query("per_page") int? perPage,
    @Query("sort_by") String? sortBy,
    @Query("sort_desc") bool? sortDesc,
    @Query("status") String? status,
  });
}

/// Provider exposing the [PaymentsClient] dependency.
final paymentsClientProvider = Provider<PaymentsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentsClient(dio);
});
