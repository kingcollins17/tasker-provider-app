import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/bank_providers.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/ui/widgets/select_bank_page.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';

class UpdatePayoutAccountScreen extends ConsumerStatefulWidget {
  const UpdatePayoutAccountScreen({super.key});

  @override
  ConsumerState<UpdatePayoutAccountScreen> createState() =>
      _UpdatePayoutAccountScreenState();
}

class _UpdatePayoutAccountScreenState
    extends ConsumerState<UpdatePayoutAccountScreen> {
  final _accountNumberController = TextEditingController();
  SupportedBank? _selectedBank;

  @override
  void dispose() {
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectBank() async {
    final bank = await SelectBankPage.show(context);
    if (bank != null && bank.bankCode != _selectedBank?.bankCode) {
      setState(() {
        _selectedBank = bank;
      });
    }
  }

  Future<void> _submit() async {
    final accountNumber = _accountNumberController.text.trim();
    if (accountNumber.length != 10 || _selectedBank == null) return;

    final verifiedData = ref
        .read(
          verifyBankProvider((
            accountNumber: accountNumber,
            bankCode: _selectedBank!.bankCode!,
          )),
        )
        .value;

    if (verifiedData == null) return;

    context.showLoading();

    await ref
        .read(userProvider.notifier)
        .updatePayoutAccount(
          bankCode: _selectedBank!.bankCode,
          bankName: _selectedBank!.name,
          accountName: verifiedData.accountName,
          accountNumber: verifiedData.accountNumber,
          onSuccess: () {
            context.hideLoading();
            Navigator.pop(context);
            
            Future.delayed(const Duration(milliseconds: 150), () {
              final rootContext = NavigatorKeys.rootNavigatorKey.currentContext;
              if (rootContext != null && rootContext.mounted) {
                rootContext.showInfo('Payout account updated successfully');
              }
            });
          },
          onError: (error) {
            context.hideLoading();
            context.showError(error);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountNumber = _accountNumberController.text.trim();
    final isReadyToVerify = _selectedBank != null && accountNumber.length == 10;

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Payout Account', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text('Bank Details', style: AppTextStyles.h3),
            // SizedBox(height: 8.h),
            Text(
              'Enter your bank account information to receive payouts.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textMuted : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: _selectBank,
              child: AbsorbPointer(
                child: AppTextField(
                  label: 'Select Bank',
                  hintText: _selectedBank?.name ?? 'Tap to select a bank',
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: _accountNumberController,
              label: 'Account Number',
              hintText: 'Enter 10-digit account number',
              keyboardType: TextInputType.number,
              maxLength: 10,
              onChanged: (value) {
                setState(() {});
              },
            ),
            SizedBox(height: 24.h),
            if (isReadyToVerify)
              Consumer(
                builder: (context, ref, child) {
                  final verifyAsync = ref.watch(
                    verifyBankProvider((
                      accountNumber: accountNumber,
                      bankCode: _selectedBank!.bankCode!,
                    )),
                  );

                  return verifyAsync.when(
                    data: (verifiedData) {
                      if (verifiedData == null) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.accent : AppColors.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color:
                                (isDark ? AppColors.accent : AppColors.primary)
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: isDark
                                      ? AppColors.accent
                                      : AppColors.primary,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Account Verified',
                                  style: AppTextStyles.bodyLarge.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.accent
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              verifiedData.accountName ?? '',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Shimmer.fromColors(
                      baseColor: isDark
                          ? AppColors.surface
                          : Colors.grey.shade200,
                      highlightColor: isDark
                          ? AppColors.border
                          : Colors.grey.shade100,
                      child: Container(
                        width: double.infinity,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                    ),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  );
                },
              ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Consumer(
            builder: (context, ref, child) {
              final canSubmit =
                  isReadyToVerify &&
                  ref
                          .watch(
                            verifyBankProvider((
                              accountNumber: accountNumber,
                              bankCode: _selectedBank!.bankCode!,
                            )),
                          )
                          .value !=
                      null;

              return PrimaryButton(
                text: 'Update Account',
                onPressed: canSubmit ? _submit : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
