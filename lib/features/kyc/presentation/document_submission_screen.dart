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
        leading: BackButton(
          color: isDark ? AppColors.textPrimary : AppColors.background,
        ),
        title: Text(
          'ID Document',
          style:
              (theme.textTheme.titleMedium?.copyWith(
                color: isDark ? AppColors.textPrimary : AppColors.background,
              )) ??
              AppTextStyles.h3,
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
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),

                    // Instructions
                    Text(
                      'Upload Your ID Document',
                      style:
                          (theme.textTheme.titleLarge?.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimary
                                : AppColors.background,
                          )) ??
                          AppTextStyles.h2.copyWith(fontSize: 24.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Take a clear photo of your ID or select an existing image from your files.',
                      style:
                          (theme.textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? AppColors.textSecondary
                                : AppColors.textMuted,
                          )) ??
                          AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: 20.h),

                    // Name match warning
                    _buildNameMatchWarning(isDark),
                    SizedBox(height: 20.h),

                    // Document Type
                    Text(
                      'Document Type',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.border,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      value: _selectedDocumentType,
                      decoration: InputDecoration(
                        hintText: 'Select document type',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textMuted,
                        ),
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: isDark
                              ? AppColors.textMuted
                              : AppColors.textMuted,
                          size: 20.r,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surface
                            : theme.colorScheme.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.r,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.border,
                            width: 1.r,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.accent
                                : AppColors.primary,
                            width: 1.5.r,
                          ),
                        ),
                      ),
                      dropdownColor: isDark
                          ? AppColors.surface
                          : theme.colorScheme.surface,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textMuted,
                      ),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimary
                            : AppColors.background,
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
                    SizedBox(height: 20.h),

                    // Document ID field
                    AppTextField(
                      controller: _documentIdController,
                      label: 'Document ID Number',
                      hintText: 'e.g. A12345678',
                      prefixIcon: Icon(
                        Icons.numbers_rounded,
                        color: isDark
                            ? AppColors.textMuted
                            : AppColors.textMuted,
                        size: 20.r,
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Preview or options
                    _selectedFile != null
                        ? _buildPreview(isDark)
                        : _buildOptions(isDark),
                  ],
                ),
              ),
            ),

            // Submi
            if (_selectedFile != null)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 10.h),
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
      children: [
        // Camera option
        _buildOptionCard(
          isDark: isDark,
          icon: Icons.camera_alt_rounded,
          title: 'Take Photo',
          description: 'Use your camera to capture your ID document.',
          gradient: const [AppColors.primary, AppColors.primaryDark],
          onTap: _captureFromCamera,
        ),
        SizedBox(height: 16.h),

        // File picker option
        _buildOptionCard(
          isDark: isDark,
          icon: Icons.folder_open_rounded,
          title: 'Choose from Files',
          description: 'Select an existing image from your device.',
          gradient: const [AppColors.secondary, AppColors.secondaryDark],
          onTap: _pickFromFiles,
        ),
        SizedBox(height: 24.h),

        // Tips
        _buildTipsCard(isDark),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildOptionCard({
    required bool isDark,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : theme.colorScheme.surface,
          borderRadius: AppDecorations.radiusLg,
          border: Border.all(color: AppColors.border, width: 1.r),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.06),
              blurRadius: 16.r,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with gradient
            Container(
              width: 56.r,
              height: 56.r,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppDecorations.radiusMd,
              ),
              child: Icon(icon, color: AppColors.textPrimary, size: 28.r),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16.sp,
                      color: isDark
                          ? AppColors.textPrimary
                          : AppColors.background,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.textMuted : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 24.r,
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
            color: isDark ? AppColors.surface : theme.colorScheme.surface,
            borderRadius: AppDecorations.radiusLg,
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.4),
              width: 1.5.r,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.06),
                blurRadius: 16.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: Image.file(
                  _selectedFile!,
                  width: double.infinity,
                  height: 240.h,
                  fit: BoxFit.cover,
                ),
              ),

              // Status bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surface
                      : theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: AppDecorations.radiusSm,
                      ),
                      child: Icon(
                        Icons.check_rounded,
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
                            'Document Selected',
                            style: AppTextStyles.buttonMedium.copyWith(
                              color: isDark
                                  ? AppColors.textPrimary
                                  : AppColors.background,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Ready to submit',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
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
        SizedBox(height: 20.h),

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
            SizedBox(width: 12.w),
            Expanded(
              child: _buildSecondaryAction(
                isDark: isDark,
                icon: Icons.folder_open_rounded,
                label: 'Reselect',
                onTap: _pickFromFiles,
              ),
            ),
            SizedBox(width: 12.w),
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
        SizedBox(height: 20.h),
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
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppDecorations.radiusMd,
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(height: 4.h),
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
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 18.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Tips for a Clear Photo',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildTipItem(isDark, 'Place your ID on a flat, dark surface'),
          SizedBox(height: 6.h),
          _buildTipItem(isDark, 'Ensure all text is clearly visible'),
          SizedBox(height: 6.h),
          _buildTipItem(isDark, 'Avoid glare and shadows'),
          SizedBox(height: 6.h),
          _buildTipItem(isDark, 'Capture the entire document'),
        ],
      ),
    );
  }

  Widget _buildTipItem(bool isDark, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.success,
            size: 14.r,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameMatchWarning(bool isDark) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppDecorations.radiusMd,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
          width: 1.r,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 20.r,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'The name on your document must match your registered name, otherwise your submission will be rejected.',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.warning,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
