import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/models/api/notifications/notification_preference.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/providers/notifications_provider.dart';

enum AppNotificationType {
  taskAccepted(
    'task_accepted',
    'Task Accepted',
    'Get notified when a task is accepted',
    Icons.check_circle_outline,
    AppColors.success,
  ),
  taskCompleted(
    'task_completed',
    'Task Completed',
    'Get notified when a task is finished',
    Icons.done_all_rounded,
    AppColors.success,
  ),
  taskCancelled(
    'task_cancelled',
    'Task Cancelled',
    'Get notified if a task gets cancelled',
    Icons.cancel_outlined,
    AppColors.error,
  ),
  paymentReceived(
    'payment_received',
    'Payment Received',
    'Updates on your received payments',
    Icons.account_balance_wallet_rounded,
    AppColors.success,
  ),
  paymentFailed(
    'payment_failed',
    'Payment Failed',
    'Alerts when a payment fails',
    Icons.error_outline_rounded,
    AppColors.error,
  ),
  newMessage(
    'new_message',
    'New Message',
    'When you receive a new message',
    Icons.message_rounded,
    AppColors.primaryLight,
  ),
  reviewReceived(
    'review_received',
    'Review Received',
    'When someone leaves a review',
    Icons.star_outline_rounded,
    AppColors.warning,
  ),
  promotion(
    'promotion',
    'Promotions',
    'Special offers and promotions',
    Icons.local_offer_outlined,
    AppColors.primary,
  ),
  securityAlert(
    'security_alert',
    'Security Alerts',
    'Important security notifications',
    Icons.security_rounded,
    AppColors.error,
  );

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const AppNotificationType(
    this.value,
    this.title,
    this.subtitle,
    this.icon,
    this.color,
  );
}

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen> {
  final Map<AppNotificationType, bool> _preferences = {
    for (var type in AppNotificationType.values) type: false,
  };
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    if (!_initialized && state.value?.preferences != null) {
      final prefs = state.value!.preferences!;
      for (final type in AppNotificationType.values) {
        _preferences[type] = _getPref(prefs, type.value);
      }
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          'Notifications',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: state.isLoading && !_initialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      children: [
                        Text(
                          'Manage how you receive updates and alerts.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        ...AppNotificationType.values.map((type) {
                          return _buildPreferenceCard(
                            title: type.title,
                            subtitle: type.subtitle,
                            icon: type.icon,
                            iconColor: type.color,
                            value: _preferences[type] ?? false,
                            onChanged: (val) {
                              setState(() => _preferences[type] = val);
                              _savePreferences();
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  bool _getPref(List<NotificationPreference> prefs, String notificationType) {
    return prefs
            .firstWhere(
              (p) => p.notificationType == notificationType,
              orElse: () => NotificationPreference(
                notificationType: notificationType,
                enabled: false,
              ),
            )
            .enabled ??
        false;
  }

  void _savePreferences() {
    context.showLoading();
    final newPrefs = _preferences.entries
        .map(
          (e) => NotificationPreference(
            notificationType: e.key.value,
            enabled: e.value,
          ),
        )
        .toList();

    ref
        .read(notificationsProvider.notifier)
        .updatePreferences(
          newPrefs,
          onSuccess: () {
            if (mounted) {
              context.hideLoading();
              context.showInfo('Preferences updated successfully');
            }
          },
          onError: (err) {
            if (mounted) {
              context.hideLoading();
              context.showError(err);
              setState(() {
                _initialized = false;
              });
            }
          },
        );
  }

  Widget _buildPreferenceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}
