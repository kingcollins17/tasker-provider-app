import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/ui/designs/designs.dart';
import '../../../../core/providers/user_provider.dart';

/// Badge widget showing the current KYC verification status.
class KycBadge extends StatelessWidget {
  const KycBadge({super.key, required this.status});

  final KycStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      KycStatus.approved => ('Verified', AppColors.success),
      KycStatus.pending => ('Pending', AppColors.warning),
      KycStatus.submitted => ('Submitted', AppColors.warning),
      KycStatus.underReview => ('Under Review', AppColors.primaryLight),
      KycStatus.rejected => ('Rejected', AppColors.error),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == KycStatus.approved
                ? Icons.verified_rounded
                : Icons.info_outline_rounded,
            color: color,
            size: 14.r,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
