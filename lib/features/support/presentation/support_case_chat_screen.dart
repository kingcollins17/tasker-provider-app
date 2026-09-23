import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/providers.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';

class SupportCaseChatScreen extends ConsumerStatefulWidget {
  final String caseId;

  const SupportCaseChatScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<SupportCaseChatScreen> createState() =>
      _SupportCaseChatScreenState();
}

class _SupportCaseChatScreenState extends ConsumerState<SupportCaseChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 150) {
      ref.read(caseMessagesProvider(widget.caseId).notifier).fetchMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final body = _textController.text.trim();
    if (body.isEmpty) return;

    _textController.clear();
    context.showLoading(null, 'Sending message...');

    ref.read(customerSupportNotifierProvider(null).notifier).sendMessage(
          widget.caseId,
          SendSupportMessageRequest(body: body),
          onSuccess: () {
            if (mounted) {
              context.hideLoading();
              ref.invalidate(caseMessagesProvider(widget.caseId));
            }
          },
          onError: (err) {
            if (mounted) {
              context.hideLoading();
              context.showError(err);
            }
          },
        );
  }

  Future<void> _pickAndUploadAttachment() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (bottomContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upload Attachment',
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: AppColors.primary, size: 20.r),
                ),
                title: const Text('Choose Photo from Gallery'),
                onTap: () async {
                  Navigator.pop(bottomContext);
                  final picked = await _imagePicker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    _uploadFile(File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.insert_drive_file_rounded,
                      color: AppColors.primary, size: 20.r),
                ),
                title: const Text('Choose File Document'),
                onTap: () async {
                  Navigator.pop(bottomContext);
                  final result = await FilePicker.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    _uploadFile(File(result.files.single.path!));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadFile(File file) {
    context.showLoading(null, 'Uploading attachment...');

    ref.read(customerSupportNotifierProvider(null).notifier).uploadAttachment(
          widget.caseId,
          file,
          onSuccess: () {
            if (mounted) {
              context.hideLoading();
              context.showMessage('File uploaded successfully!');
              ref.invalidate(caseMessagesProvider(widget.caseId));
              ref.invalidate(caseAttachmentsProvider(widget.caseId));
            }
          },
          onError: (err) {
            if (mounted) {
              context.hideLoading();
              context.showError(err);
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(caseMessagesProvider(widget.caseId));
    final caseDetailsAsync = ref.watch(userCaseDetailsProvider(widget.caseId));

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final caseSubject = caseDetailsAsync.value?.subject ?? 'Support Chat';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              caseSubject,
              style: AppTextStyles.h3.copyWith(
                fontSize: 14.5.sp,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Case #${widget.caseId.length > 8 ? widget.caseId.substring(0, 8) : widget.caseId}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20.r),
            onPressed: () {
              ref.invalidate(caseMessagesProvider(widget.caseId));
            },
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await ref
                      .read(caseMessagesProvider(widget.caseId).notifier)
                      .refresh();
                },
                child: messagesAsync.when(
                  data: (messages) {
                    if (messages.isEmpty) {
                      return _buildEmptyState(isDark);
                    }

                    return ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      itemCount: messages.length,
                      separatorBuilder: (context, index) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildChatBubble(msg, isDark);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (e, st) => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Failed to load messages: $e'),
                        SizedBox(height: 8.h),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(
                              caseMessagesProvider(widget.caseId),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Input Bar
            _buildBottomInputBar(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(SupportMessage msg, bool isDark) {
    final senderType = (msg.senderType ?? 'USER').toUpperCase().trim();
    final isUser = senderType == 'USER' || senderType == 'CUSTOMER';

    final formattedTime = msg.createdAt != null
        ? DateFormat.jm().format(msg.createdAt!)
        : '';

    final bubbleBg = isUser
        ? AppColors.primary
        : isDark
            ? AppColors.surface
            : Colors.grey[200]!;

    final textColor = isUser
        ? Colors.white
        : isDark
            ? AppColors.textPrimary
            : const Color(0xFF0F172A);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(isUser ? 14.r : 2.r),
            bottomRight: Radius.circular(isUser ? 2.r : 14.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Text(
                'Support Agent',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: 2.h),
            ],
            Text(
              msg.body ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontSize: 12.5.sp,
                height: 1.3,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              formattedTime,
              style: AppTextStyles.bodySmall.copyWith(
                color: isUser
                    ? Colors.white70
                    : isDark
                        ? AppColors.textMuted
                        : Colors.grey[600]!,
                fontSize: 9.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputBar(bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.border.withValues(alpha: isDark ? 0.3 : 0.6),
            width: 1.r,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            onPressed: _pickAndUploadAttachment,
            icon: Icon(
              Icons.attach_file_rounded,
              color: AppColors.primary,
              size: 20.r,
            ),
            tooltip: 'Attach file or image',
          ),
          SizedBox(width: 2.w),

          // Message Text Input
          Expanded(
            child: TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
                fontSize: 12.5.sp,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12.5.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                filled: true,
                fillColor: isDark ? AppColors.background : Colors.grey[100]!,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),

          // Send Button
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 36.r,
              height: 36.r,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 16.r,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 40.r,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'No messages yet',
            style: AppTextStyles.h3.copyWith(fontSize: 15.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'Send a message to start communicating with support.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}
