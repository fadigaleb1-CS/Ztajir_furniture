import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class StaticAppBar extends StatelessWidget implements PreferredSizeWidget {
  const StaticAppBar({
    super.key,
    required this.appBarName,
    this.leading,
    this.actions, // 🔥 إضافة خاصية actions
  });

  final String appBarName;
  final Widget? leading;
  final List<Widget>? actions; // 🔥 قائمة الأزرار الإضافية

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      foregroundColor: AppColors.whiteColor,
      leading: leading,
      actions: actions, // 🔥 تمرير actions إلى AppBar
      title: Text(
        appBarName,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 22.sp,
        ),
      ),
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.w)),
      ),
    );
  }
}
