import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api.dart';
import '../models/models.dart';

final supportedBanksProvider = FutureProvider<List<SupportedBank>>((ref) async {
  final client = ref.watch(payoutsClientProvider);
  final response = await client.getSupportedBanks();
  if (response.isError) {
    throw Exception(response.detail ?? 'Failed to fetch supported banks');
  }
  return response.data ?? [];
});

final verifyBankProvider =
    FutureProvider.family<
      VerifyAccountData?,
      ({String accountNumber, String bankCode})
    >((ref, args) async {
      final client = ref.watch(payoutsClientProvider);
      final response = await client.verifyBankAccount(
        args.accountNumber,
        args.bankCode,
      );
      if (response.isError) {
        throw Exception(response.detail ?? 'Failed to verify bank account');
      }
      return response.data;
    });
