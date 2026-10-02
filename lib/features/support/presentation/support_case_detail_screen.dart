import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../support_routes.dart';

class SupportCaseDetailScreen extends ConsumerWidget {
  final String caseId;

  const SupportCaseDetailScreen({
    super.key,
    required this.caseId,
  });

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (context.mounted) {
        context.showError('Could not open file URL');
      }
    } catch (_) {
      if (context.mounted) {
        context.showError('Could not open file URL');
      }
    }
  }

  void _closeTicket(BuildContext context, WidgetRef ref) {
    context.showLoading(null, 'Closing support ticket...');

    ref.read(customerSupportNotifierProvider(null).notifier).closeCase(
          caseId,
          onSuccess: () {
            if (context.mounted) {
              context.hideLoading();
              context.showMessage('Support ticket closed');
              ref.invalidate(userCaseDetailsProvider(caseId));
            }
          },
          onError: (err) {
            if (context.mounted) {
              context.hideLoading();
              context.showError(err);
            }
          },
        );
  }

  void _reopenTicket(BuildContext context, WidgetRef ref) {
    context.showLoading(null, 'Reopening support ticket...');

    ref.read(customerSupportNotifierProvider(null).notifier).reopenCase(
          caseId,
          onSuccess: () {
            if (context.mounted) {
              context.hideLoading();
              context.showMessage('Support ticket reopened');
              ref.invalidate(userCaseDetailsProvider(caseId));
            }
          },
          onError: (err) {
            if (context.mounted) {
              context.hideLoading();
              context.showError(err);
            }
          },
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caseAsync = ref.watch(userCaseDetailsProvider(caseId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Text(
          'Ticket Details',
          style: AppTextStyles.h3.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          caseAsync.maybeWhen(
            data: (caseItem) {
              if (caseItem == null) return const SizedBox.shrink();
              final statusStr =
                  (caseItem.status ?? 'OPEN').toUpperCase().trim();
              final isClosed =
                  statusStr == 'CLOSED' || statusStr == 'RESOLVED';

              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color:
                      isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                  size: 20.r,
                ),
                onSelected: (value) {
                  if (value == 'close') {
                    _closeTicket(context, ref);
                  } else if (value == 'reopen') {
                    _reopenTicket(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  if (isClosed)
                    PopupMenuItem(
                      value: 'reopen',
                      child: Text(
                        'Reopen Ticket',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    )
                  else
                    PopupMenuItem(
                      value: 'close',
                      child: Text(
                        'Close Ticket',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: caseAsync.when(
          data: (caseItem) {
            if (caseItem == null) {
              return _buildNotFoundState(context);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                ref.invalidate(userCaseDetailsProvider(caseId));
                ref.invalidate(caseAttachmentsProvider(caseId));
                await ref.read(userCaseDetailsProvider(caseId).future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ticket Header Card
                    _buildHeaderCard(context, caseItem, isDark),
                    SizedBox(height: 12.h),

                    // Description Card
                    _buildSectionTitle('Ticket Description'),
                    SizedBox(height: 6.h),
                    _buildDescriptionCard(context, caseItem, isDark),
                    SizedBox(height: 12.h),

                    // Attachments Section
                    _buildSectionTitle('Attachments'),
                    SizedBox(height: 6.h),
                    _buildAttachmentsSection(context, ref, isDark),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildShimmerDetails(context, isDark),
          error: (err, st) => _buildErrorState(context, ref),
        ),
      ),
      bottomNavigationBar: caseAsync.maybeWhen(
        data: (caseItem) {
          if (caseItem == null) return null;

          return Container(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 10.h,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
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
              child: PrimaryButton(
                text: 'Open Chat & Messages',
                onPressed: () {
                  context.pushNamed(
                    SupportRoutes.caseChatRoute,
                    pathParameters: {'caseId': caseId},
                  );
                },
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.h3.copyWith(
        fontSize: 12.5.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    SupportCase item,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final statusStr = (item.status ?? 'OPEN').toUpperCase().trim();
    final isClosed = statusStr == 'CLOSED' || statusStr == 'RESOLVED';
    final statusColor = isClosed
        ? Colors.grey
        : statusStr == 'IN_PROGRESS' || statusStr == 'PENDING'
            ? AppColors.warning
            : AppColors.primary;

    final createdStr = item.createdAt != null
        ? DateFormat.yMMMd().add_jm().format(item.createdAt!)
        : 'Unknown';

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  (item.type ?? 'GENERAL').replaceAll('_', ' '),
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
              if (item.priority != null) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    item.priority!.toUpperCase(),
                    style: AppTextStyles.label.copyWith(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 8.5.sp,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  statusStr,
                  style: AppTextStyles.label.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            item.subject ?? 'No Subject',
            style: AppTextStyles.h3.copyWith(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 11.r,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 4.w),
              Text(
                'Created: $createdStr',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(
    BuildContext context,
    SupportCase item,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final text = item.description ?? 'No description provided.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1.r,
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontSize: 11.5.sp,
          height: 1.35,
          color: isDark ? AppColors.textPrimary : const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final attachmentsAsync = ref.watch(caseAttachmentsProvider(caseId));
    final theme = Theme.of(context);

    return attachmentsAsync.when(
      data: (attachments) {
        if (attachments.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppDecorations.radiusLg,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
                width: 1.r,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.attachment_rounded,
                  color: AppColors.textMuted,
                  size: 20.r,
                ),
                SizedBox(width: 10.w),
                Text(
                  'No file attachments uploaded yet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: attachments.map((att) {
            final fileName = att.filename ?? 'Attachment';
            final storageKey = att.storageKey;
            final sizeKb = att.size != null
                ? '${(att.size! / 1024).toStringAsFixed(1)} KB'
                : '';

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppDecorations.radiusMd,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1.r,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.insert_drive_file_rounded,
                        color: AppColors.primary,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (sizeKb.isNotEmpty)
                            Text(
                              sizeKb,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                                fontSize: 11.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (storageKey != null && storageKey.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.open_in_new_rounded,
                          color: AppColors.primary,
                          size: 18.r,
                        ),
                        onPressed: () => _launchUrl(context, storageKey),
                        tooltip: 'Open attachment',
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(16.r),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, st) => const SizedBox.shrink(),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48.r, color: AppColors.textMuted),
          SizedBox(height: 12.h),
          Text(
            'Ticket Not Found',
            style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 48.r, color: AppColors.error),
          SizedBox(height: 12.h),
          Text(
            'Failed to load ticket details',
            style: AppTextStyles.h3.copyWith(fontSize: 15.sp),
          ),
          SizedBox(height: 12.h),
          OutlinedButton(
            onPressed: () {
              ref.invalidate(userCaseDetailsProvider(caseId));
              ref.invalidate(caseAttachmentsProvider(caseId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerDetails(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.surface;
    final highlightColor = isDark ? AppColors.border : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          children: [
            Container(height: 120.h, color: Colors.white),
            SizedBox(height: 16.h),
            Container(height: 150.h, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
