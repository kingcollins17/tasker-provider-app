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
}

/// Provider exposing the [PaymentsClient] dependency.
final paymentsClientProvider = Provider<PaymentsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentsClient(dio);
});
