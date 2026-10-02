import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/models.dart';
import '../../providers/bank_providers.dart';
import '../designs/colors.dart';
import '../designs/text_styles.dart';
import 'app_text_field.dart';
import 'primary_button.dart';

class SelectBankPage extends ConsumerStatefulWidget {
  const SelectBankPage({super.key});

  static Future<SupportedBank?> show(BuildContext context) {
    return Navigator.push<SupportedBank>(
      context,
      MaterialPageRoute(builder: (context) => const SelectBankPage()),
    );
  }

  @override
  ConsumerState<SelectBankPage> createState() => _SelectBankPageState();
}

class _SelectBankPageState extends ConsumerState<SelectBankPage> {
  String _searchQuery = '';
  SupportedBank? _selectedBank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final banksAsync = ref.watch(supportedBanksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Bank', style: AppTextStyles.h3.copyWith(fontSize: 18.sp)),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: AppTextField(
              hintText: 'Search bank name...',
              prefixIcon: Icon(
                Icons.search,
                color: isDark ? AppColors.textMuted : const Color(0xFF94A3B8),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: banksAsync.when(
              data: (banks) {
                final filteredBanks = banks.where((bank) {
                  final name = bank.name?.toLowerCase() ?? '';
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredBanks.isEmpty) {
                  return Center(
                    child: Text(
                      'No banks found.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  itemCount: filteredBanks.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1.h,
                    thickness: 1.h,
                    color: isDark
                        ? AppColors.border.withValues(alpha: 0.5)
                        : const Color(0xFFF1F5F9),
                  ),
                  itemBuilder: (context, index) {
                    final bank = filteredBanks[index];
                    final isSelected =
                        _selectedBank?.bankCode == bank.bankCode;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedBank = bank;
                        });
                      },
                      borderRadius: BorderRadius.circular(10.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40.r,
                              height: 40.r,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.surface
                                    : const Color(0xFFF8FAFC),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: bank.logoUrl != null &&
                                      bank.logoUrl!.isNotEmpty
                                  ? Image.network(
                                      bank.logoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.account_balance_rounded,
                                          size: 20.r,
                                          color: isDark
                                              ? AppColors.textMuted
                                              : const Color(0xFF94A3B8),
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.account_balance_rounded,
                                      size: 20.r,
                                      color: isDark
                                          ? AppColors.textMuted
                                          : const Color(0xFF94A3B8),
                                    ),
                            ),
                            SizedBox(width: 14.w),
                            Expanded(
                              child: Text(
                                bank.name ?? 'Unknown Bank',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? (isDark
                                          ? AppColors.accent
                                          : AppColors.primary)
                                      : (isDark
                                          ? AppColors.textPrimary
                                          : const Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark
                                    ? AppColors.accent
                                    : AppColors.primary,
                                size: 20.r,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: 8,
                separatorBuilder: (context, index) => Divider(
                  height: 1.h,
                  thickness: 1.h,
                  color: isDark
                      ? AppColors.border.withValues(alpha: 0.5)
                      : const Color(0xFFF1F5F9),
                ),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 12.h,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: isDark
                          ? AppColors.border
                          : Colors.grey.shade300,
                      highlightColor: isDark
                          ? AppColors.surface
                          : Colors.grey.shade100,
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Container(
                            height: 16.h,
                            width: 160.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              error: (error, stackTrace) => Center(
                child: Text(
                  'Failed to load banks.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: PrimaryButton(
            text: 'Continue',
            onPressed: _selectedBank != null
                ? () {
                    Navigator.pop(context, _selectedBank);
                  }
                : null,
          ),
        ),
      ),
    );
  }
}
