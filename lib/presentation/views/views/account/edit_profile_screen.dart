import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/data/mock/mock_data.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/auth_widgets/custom_text_field.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user; // Might be null

    String first = '';
    String last = '';

    if (user != null) {
      if (user.firstName.isNotEmpty) {
        first = user.firstName;
        last = user.lastName;
      } else {
        // Fallback if only name is available
        final parts = (user.name).split(' ');
        if (parts.isNotEmpty) {
          first = parts.first;
          if (parts.length > 1) {
            last = parts.sublist(1).join(' ');
          }
        }
      }
    } else {
      // Mock data fallback
      final parts = MockData.currentUser.name.split(' ');
      if (parts.isNotEmpty) {
        first = parts.first;
        if (parts.length > 1) {
          last = parts.sublist(1).join(' ');
        }
      }
    }

    _firstNameController = TextEditingController(text: first);
    _lastNameController = TextEditingController(text: last);
    _emailController = TextEditingController(
      text: user?.email ?? MockData.currentUser.email,
    );
    _phoneController = TextEditingController(
      text: user?.phone ?? MockData.currentUser.phone ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e, stackTrace) {
      debugPrint('خطأ اختيار الصورة: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        SnackBarHelper.show(
          context: context,
          message: 'خطأ: ${e.toString()}',
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  void _showImagePickerSheet() {
    var loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.w)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: AppColors.darkGreyColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.w),
              ),
            ),
            Text(
              loc.translate('change_photo'),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'الكاميرا',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildPickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'المعرض',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 32.w),
          ),
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.darkGreyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Combine first and last name for now, as existing AuthProvider expects 'name'
    // It splits it internally anyway.
    // Ideally we'd update AuthProvider to take firstName/lastName.
    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';

    await authProvider.updateProfile(
      name: fullName,
      email: _emailController.text,
      phone: _phoneController.text,
      avatarUrl: _selectedImage?.path,
    );

    var loc = AppLocalizations.of(context)!;
    SnackBarHelper.show(
      context: context,
      message: loc.translate('profile_updated'),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final avatarUrl =
        authProvider.user?.avatarUrl ?? MockData.currentUser.avatarUrl;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: loc.translate('edit_profile_title')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // صورة البروفايل
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryColor.withOpacity(0.3),
                        width: 3.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 55.w,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: _getProfileImage(authProvider),
                      child: _selectedImage == null && avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50.w,
                              color: AppColors.primaryColor,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePickerSheet,
                      child: Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.whiteColor,
                            width: 2.w,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.whiteColor,
                          size: 18.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: _showImagePickerSheet,
              child: Text(
                loc.translate('change_photo'),
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // حقول الإدخال
            // حقول الإدخال
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _firstNameController,
                    labelText: loc.translate('first_name'),
                    hintText: loc.translate('first_name'),
                    icon: Icons.person_outline_rounded,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: CustomTextField(
                    controller: _lastNameController,
                    labelText: loc.translate('last_name'),
                    hintText: loc.translate('last_name'),
                    icon: Icons.person_outline_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _emailController,
              labelText: loc.translate('email_hint'),
              hintText: loc.translate('email_hint'),
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: _phoneController,
              labelText: loc.translate('phone_number'),
              hintText: loc.translate('phone_number'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 40.h),

            // زر الحفظ
            if (authProvider.isLoading)
              SizedBox(
                height: 54.h,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              )
            else
              PrimaryButton(
                text: loc.translate('save'),
                onPressed: _saveProfile,
                height: 54.h,
                borderRadius: 16.w,
              ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage(AuthProvider authProvider) {
    // Fallsback logically
    final avatarUrl =
        authProvider.user?.avatarUrl ?? MockData.currentUser.avatarUrl;

    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (avatarUrl != null) {
      if (avatarUrl.startsWith('http')) {
        return NetworkImage(avatarUrl);
      } else if (avatarUrl.startsWith('/') || avatarUrl.contains('\\')) {
        return FileImage(File(avatarUrl));
      } else {
        return AssetImage(avatarUrl);
      }
    }
    return null;
  }
}
