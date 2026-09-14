import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';

class DocumentSubmissionResult {
  final File file;
  final String idType;
  final String idNumber;

  DocumentSubmissionResult({
    required this.file,
    required this.idType,
    required this.idNumber,
  });
}

/// Screen for submitting identity documents via camera or file picker.
///
/// Returns the selected [File] on submit, or `null` if cancelled.
class DocumentSubmissionScreen extends StatefulWidget {
  const DocumentSubmissionScreen({super.key});

  @override
  State<DocumentSubmissionScreen> createState() =>
      _DocumentSubmissionScreenState();
}

class _DocumentSubmissionScreenState extends State<DocumentSubmissionScreen> {
  File? _selectedFile;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _documentIdController = TextEditingController();
  String? _selectedDocumentType;
  final List<Map<String, String>> _documentTypes = const [
    {'value': 'national id', 'label': 'National ID'},
    {'value': 'passport', 'label': 'Passport'},
    {'value': 'nin', 'label': 'NIN'},
    {'value': 'voters card', 'label': 'Voter\'s Card'},
    {'value': 'drivers liscence', 'label': 'Driver\'s License'},
  ];

  @override
  void dispose() {
    _documentIdController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (photo != null && mounted) {
        setState(() {
          _selectedFile = File(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showError('Could not access camera. Please check permissions.');
      }
    }
  }

  Future<void> _pickFromFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null && mounted) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        context.showError('Could not access file picker. Please try again.');
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _handleSubmit() {
    if (_selectedDocumentType == null) {
      context.showError('Please select a document type.');
      return;
    }
    if (_selectedFile == null) {
      context.showError('Please select or capture a document image first.');
      return;
    }
    if (_documentIdController.text.trim().isEmpty) {
      context.showError('Please enter your document ID number.');
      return;
    }
    Navigator.pop(
      context,
      DocumentSubmissionResult(
        file: _selectedFile!,
        idType: _selectedDocumentType!,
        idNumber: _documentIdController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        title: Text(
          'ID Document Verification',
          style: AppTextStyles.h3.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.h),

                    // Compact Name Match Warning Banner
                    _buildNameMatchWarning(isDark),
                    SizedBox(height: 14.h),

                    // Document Type
                    Text(
                      'Document Type',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      decoration: InputDecoration(
                        hintText: 'Select document type',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppColors.textMuted,
                          size: 18.r,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.r,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.r,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.accent
                                : AppColors.primary,
                            width: 1.2.r,
                          ),
                        ),
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                        size: 20.r,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.5.sp,
                        color: isDark
                            ? AppColors.textPrimary
                            : const Color(0xFF0F172A),
                      ),
                      items: _documentTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['value'],
                          child: Text(type['label']!),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedDocumentType = val;
                        });
                      },
                    ),
                    SizedBox(height: 14.h),

                    // Document ID field
                    AppTextField(
                      controller: _documentIdController,
                      label: 'Document ID Number',
                      hintText: 'e.g. A12345678',
                      prefixIcon: Icon(
                        Icons.numbers_rounded,
                        color: AppColors.textMuted,
                        size: 18.r,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Preview or options
                    _selectedFile != null
                        ? _buildPreview(isDark)
                        : _buildOptions(isDark),
                  ],
                ),
              ),
            ),

            // Submit Button
            if (_selectedFile != null)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 12.h),
                child: PrimaryButton(
                  text: 'Submit Document',
                  onPressed: _handleSubmit,
                  icon: Icons.upload_file_rounded,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Upload Document Photo',
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
            color: isDark ? AppColors.textSecondary : AppColors.textMuted,
          ),
        ),
        SizedBox(height: 8.h),
        // Side by side action tiles
        Row(
          children: [
            Expanded(
              child: _buildOptionTile(
                isDark: isDark,
                icon: Icons.camera_alt_rounded,
                title: 'Take Photo',
                color: AppColors.primary,
                onTap: _captureFromCamera,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildOptionTile(
                isDark: isDark,
                icon: Icons.folder_open_rounded,
                title: 'Choose File',
                color: AppColors.secondary,
                onTap: _pickFromFiles,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),

        // Compact tips banner
        _buildTipsCard(isDark),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildOptionTile({
    required bool isDark,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.r,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppDecorations.radiusMd,
              ),
              child: Icon(icon, color: color, size: 20.r),
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: AppTextStyles.buttonMedium.copyWith(
                fontSize: 13.sp,
                color: isDark ? AppColors.textPrimary : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(bool isDark) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Document preview
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppDecorations.radiusLg,
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.4),
              width: 1.2.r,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.05),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                child: Image.file(
                  _selectedFile!,
                  width: double.infinity,
                  height: 160.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Status bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Theme.of(context).colorScheme.surface
                      : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(14.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28.r,
                      height: 28.r,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: AppDecorations.radiusSm,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: AppColors.success,
                        size: 16.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Document Selected',
                            style: AppTextStyles.buttonMedium.copyWith(
                              fontSize: 12.5.sp,
                            ),
                          ),
                          Text(
                            'Ready to submit',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 14.h),

        // Retake / Reselect buttons
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                isDark: isDark,
                icon: Icons.camera_alt_rounded,
                label: 'Retake',
                onTap: _captureFromCamera,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildSecondaryAction(
                isDark: isDark,
                icon: Icons.folder_open_rounded,
                label: 'Reselect',
                onTap: _pickFromFiles,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildSecondaryAction(
                isDark: isDark,
                icon: Icons.delete_outline_rounded,
                label: 'Remove',
                onTap: _clearSelection,
                isDestructive: true,
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
      ],
    );
  }

  Widget _buildSecondaryAction({
    required bool isDark,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16.r),
            SizedBox(width: 6.w),
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.primary,
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Tips: Ensure bright lighting, no glare, and clear text.',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textMuted,
                fontSize: 11.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameMatchWarning(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 1.r,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.warning,
            size: 16.r,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Name on document must match your registered profile name.',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.warning,
                fontSize: 11.5.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
