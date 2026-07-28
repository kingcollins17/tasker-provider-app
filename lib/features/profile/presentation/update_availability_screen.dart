import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tasker_app/core/router/navigator_keys.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/provider_availability_provider.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';

class _DayState {
  final int dayOfWeek; // 1 = Sunday, ..., 7 = Saturday
  final String name;
  bool isAvailable;
  TimeOfDay startTime;
  TimeOfDay endTime;

  _DayState({
    required this.dayOfWeek,
    required this.name,
    required this.isAvailable,
    required this.startTime,
    required this.endTime,
  });
}

class UpdateAvailabilityScreen extends ConsumerStatefulWidget {
  const UpdateAvailabilityScreen({super.key});

  @override
  ConsumerState<UpdateAvailabilityScreen> createState() =>
      _UpdateAvailabilityScreenState();
}

class _UpdateAvailabilityScreenState
    extends ConsumerState<UpdateAvailabilityScreen> {
  List<_DayState>? _days;

  static const Map<int, String> _dayNames = {
    1: 'Sunday',
    2: 'Monday',
    3: 'Tuesday',
    4: 'Wednesday',
    5: 'Thursday',
    6: 'Friday',
    7: 'Saturday',
  };

  void _initFromAvailability(List<ProviderAvailability> initialList) {
    const defaultStart = TimeOfDay(hour: 9, minute: 0);
    const defaultEnd = TimeOfDay(hour: 18, minute: 0);

    // If initial list is empty or null, initialize all weekdays (1..7) to 9 AM - 6 PM
    final isListEmpty = initialList.isEmpty;

    final Map<int, ProviderAvailability> map = {
      for (final item in initialList)
        if (item.dayOfWeek != null) item.dayOfWeek!: item,
    };

    _days = List.generate(7, (index) {
      final dayOfWeek = index + 1; // 1 to 7
      final name = _dayNames[dayOfWeek] ?? 'Day $dayOfWeek';
      final existing = map[dayOfWeek];

      if (isListEmpty) {
        return _DayState(
          dayOfWeek: dayOfWeek,
          name: name,
          isAvailable: true,
          startTime: defaultStart,
          endTime: defaultEnd,
        );
      }

      if (existing != null) {
        return _DayState(
          dayOfWeek: dayOfWeek,
          name: name,
          isAvailable: true,
          startTime: existing.startTimeOfDay ?? defaultStart,
          endTime: existing.endTimeOfDay ?? defaultEnd,
        );
      }

      return _DayState(
        dayOfWeek: dayOfWeek,
        name: name,
        isAvailable: false,
        startTime: defaultStart,
        endTime: defaultEnd,
      );
    });
  }

  Future<void> _pickTime({
    required _DayState day,
    required bool isStart,
  }) async {
    final initial = isStart ? day.startTime : day.endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          day.startTime = picked;
        } else {
          day.endTime = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_days == null) return;

    final activeBlocks = _days!
        .where((d) => d.isAvailable)
        .map(
          (d) => AvailabilityBlock.fromTimeOfDay(
            dayOfWeek: d.dayOfWeek,
            startTime: d.startTime,
            endTime: d.endTime,
          ),
        )
        .toList();

    context.showLoading();

    await ref.read(providerAvailabilityProvider.notifier).updateAvailability(
          activeBlocks,
          onSuccess: () {
            context.hideLoading();
            Navigator.pop(context);

            Future.delayed(const Duration(milliseconds: 150), () {
              final rootContext =
                  NavigatorKeys.rootNavigatorKey.currentContext;
              if (rootContext != null && rootContext.mounted) {
                rootContext.showInfo(
                  'Availability schedule updated successfully',
                );
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
    final availabilityAsync = ref.watch(providerAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Working Availability', style: AppTextStyles.h3),
        centerTitle: true,
      ),
      body: availabilityAsync.when(
        data: (initialList) {
          if (_days == null) {
            _initFromAvailability(initialList);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set your weekly working days and hours so clients know when you\'re available for tasks.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isDark ? AppColors.textMuted : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Quick Action Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          for (final d in _days!) {
                            d.isAvailable = true;
                          }
                        });
                      },
                      icon: Icon(Icons.select_all_rounded, size: 18.r),
                      label: Text(
                        'Enable All Days',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          const defaultStart = TimeOfDay(hour: 9, minute: 0);
                          const defaultEnd = TimeOfDay(hour: 18, minute: 0);
                          for (final d in _days!) {
                            d.isAvailable = true;
                            d.startTime = defaultStart;
                            d.endTime = defaultEnd;
                          }
                        });
                      },
                      icon: Icon(Icons.refresh_rounded, size: 18.r),
                      label: Text(
                        'Reset (9 AM - 6 PM)',
                        style: AppTextStyles.buttonMedium.copyWith(
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Weekdays List
                ..._days!.map((day) => _buildDayCard(day, isDark)),

                SizedBox(height: 32.h),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(isDark),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 48.r,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load availability schedule',
                  style: AppTextStyles.subtitle,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(providerAvailabilityProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: PrimaryButton(
            text: 'Save Availability',
            onPressed: _days != null ? _submit : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCard(_DayState day, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: day.isAvailable
            ? (isDark ? AppColors.surface : Colors.white)
            : (isDark
                ? AppColors.surface.withValues(alpha: 0.4)
                : Colors.grey.shade50),
        borderRadius: AppDecorations.radiusLg,
        border: Border.all(
          color: day.isAvailable
              ? (isDark
                  ? AppColors.border
                  : AppColors.primary.withValues(alpha: 0.3))
              : (isDark
                  ? AppColors.border.withValues(alpha: 0.3)
                  : Colors.grey.shade200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    day.name,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: day.isAvailable
                          ? (isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimary)
                          : AppColors.textMuted,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: day.isAvailable
                          ? AppColors.success.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      day.isAvailable ? 'Available' : 'Off',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: day.isAvailable
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: day.isAvailable,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    day.isAvailable = val;
                  });
                },
              ),
            ],
          ),
          if (day.isAvailable) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildTimePickerButton(
                    label: 'Start Time',
                    time: day.startTime,
                    onTap: () => _pickTime(day: day, isStart: true),
                    isDark: isDark,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18.r,
                    color: AppColors.textMuted,
                  ),
                ),
                Expanded(
                  child: _buildTimePickerButton(
                    label: 'End Time',
                    time: day.endTime,
                    onTap: () => _pickTime(day: day, isStart: false),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePickerButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDecorations.radiusMd,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.background
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(
            color: isDark
                ? AppColors.border
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  time.format(context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.access_time_rounded,
              size: 18.r,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.surface : Colors.grey.shade300,
        highlightColor: isDark ? AppColors.border : Colors.grey.shade100,
        child: Column(
          children: List.generate(
            7,
            (index) => Container(
              height: 100.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.radiusLg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
