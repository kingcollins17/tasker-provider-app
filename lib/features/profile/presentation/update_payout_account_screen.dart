import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              final rootContext =
                  NavigatorKeys.rootNavigatorKey.currentContext;
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
        leading: const BackButton(),
        title: Text('Bank Account', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: isDark ? 0.15 : 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 20.r,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    verifiedData.accountName?.toUpperCase() ??
                                        '',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimary
                                          : const Color(0xFF0F172A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Verified Account Name',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.r,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Verifying account details...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: isDark
                                  ? AppColors.textMuted
                                  : AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    error: (error, stackTrace) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(
                                alpha: isDark ? 0.15 : 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 20.r,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Verification Failed',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Could not verify account details. Check the account number & bank.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isDark
                                        ? AppColors.textMuted
                                        : AppColors.textSecondary,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16.r,
          right: 16.r,
          top: 12.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.r,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.border : const Color(0xFFE2E8F0),
              width: 1.r,
            ),
          ),
        ),
        child: SafeArea(
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
                text: 'Save',
                onPressed: canSubmit ? _submit : null,
              );
            },
          ),
        ),
      ),
    );
  }
}
