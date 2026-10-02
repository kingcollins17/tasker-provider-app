import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/models/api/users/guarantor.dart';
import '../../../../core/ui/designs/designs.dart';

/// Badge widget showing the current Guarantor / Professional Reference verification status.
class GuarantorBadge extends StatelessWidget {
  const GuarantorBadge({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      VerificationStatus.passed => ('Verified', AppColors.success),
      VerificationStatus.pending => ('Pending', AppColors.warning),
      VerificationStatus.underReview => ('Under Review', AppColors.primaryLight),
      VerificationStatus.failed => ('Action Needed', AppColors.error),
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
            status == VerificationStatus.passed
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
