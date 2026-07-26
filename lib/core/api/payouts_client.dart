import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/network_service.dart';

part 'payouts_client.g.dart';

@RestApi(baseUrl: "/api/v1/")
abstract class PayoutsClient {
  factory PayoutsClient(Dio dio, {String baseUrl}) = _PayoutsClient;

  @GET("users/payouts/banks")
  Future<BaseApiResponse<List<SupportedBank>>> getSupportedBanks();

  @POST("users/payouts/account")
  Future<BaseApiResponse> createOrUpdatePaymentAccount(
    @Body() CreatePaymentAccountRequest request,
  );

  @GET("users/payouts/verify-account")
  Future<BaseApiResponse<VerifyAccountData>> verifyBankAccount(
    @Query("account_number") String accountNumber,
    @Query("bank_code") String bankCode,
  );
}

/// Provider exposing the [PayoutsClient] dependency.
final payoutsClientProvider = Provider<PayoutsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return PayoutsClient(dio);
});
