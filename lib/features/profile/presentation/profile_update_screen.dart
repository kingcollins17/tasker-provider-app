import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ui/designs/designs.dart';
import '../../../core/ui/widgets/app_text_field.dart';
import '../../../core/ui/widgets/primary_button.dart';
import '../../../core/utils/extensions/flushbar_context_ext.dart';
import '../../../core/utils/extensions/loading_context_ext.dart';
import '../../../core/providers/providers.dart';

class ProfileUpdateScreen extends ConsumerStatefulWidget {
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? gender;

  const ProfileUpdateScreen({
    super.key,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.gender,
  });

  @override
  ConsumerState<ProfileUpdateScreen> createState() =>
      _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends ConsumerState<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);

    // Strip +234 if present for the form, or keep it.
    // To make it easy, we will keep what was provided. If it starts with +234, we might strip it so the user can edit just the number.
    String initialPhone = widget.phoneNumber ?? '';
    if (initialPhone.startsWith('+234')) {
      initialPhone = initialPhone.substring(4);
    }
    _phoneController = TextEditingController(text: initialPhone);

    final initialGender = widget.gender?.toLowerCase().trim();
    if (['male', 'female', 'other'].contains(initialGender)) {
      _selectedGender = initialGender;
    } else {
      _selectedGender = null;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.showLoading();

      String phone = _phoneController.text.trim();
      if (phone.isNotEmpty) {
        if (phone.startsWith('0')) {
          phone = phone.substring(1);
        }
        phone = '+234$phone';
      }

      final changedPhone = phone.isNotEmpty && phone != widget.phoneNumber;

      ref
          .read(userProvider.notifier)
          .updateProviderProfile(
            firstName: _firstNameController.text.trim().isNotEmpty
                ? _firstNameController.text.trim()
                : null,
            lastName: _lastNameController.text.trim().isNotEmpty
                ? _lastNameController.text.trim()
                : null,
            phoneNumber: phone.isNotEmpty ? phone : null,
            gender: _selectedGender,
            onSuccess: () {
              context.hideLoading();

              // Return success and the new phone if it changed
              context.pop({
                'success': true,
                'newPhone': changedPhone ? phone : null,
              });
            },
            onError: (err) {
              context.hideLoading();
              context.showError(err);
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Update Profile',
          style: AppTextStyles.h3.copyWith(
            color: isDark ? AppColors.textPrimary : AppColors.background,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _firstNameController,
                label: 'First Name',
                hintText: 'Enter your first name',
              ),
              AppSpacing.hMd,
              AppTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hintText: 'Enter your last name',
              ),
              AppSpacing.hMd,
              AppTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hintText: '8012345678',
                keyboardType: TextInputType.phone,
                maxLength: 10,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 12.w),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🇳🇬 +234',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimary
                              : const Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppSpacing.wSm,
                      Container(
                        width: 1.w,
                        height: 16.h,
                        color: isDark
                            ? AppColors.border
                            : const Color(0xFFE2E8F0),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.hMd,
              DropdownButtonFormField<String>(
                value: _selectedGender,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimary
                      : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(
                    borderRadius: AppDecorations.radiusMd,
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              AppSpacing.hXl,
              PrimaryButton(text: 'Save Changes', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
