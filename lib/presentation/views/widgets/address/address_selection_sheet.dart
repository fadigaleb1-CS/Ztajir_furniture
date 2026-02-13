import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';

class AddressSelectionSheet extends StatelessWidget {
  final VoidCallback onManualTap;
  final VoidCallback onMapTap;

  const AddressSelectionSheet({
    super.key,
    required this.onManualTap,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.darkGreyColor,
              borderRadius: BorderRadius.circular(10.w),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            loc.translate('add_address_via'),
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 25.h),
          SelectionTile(
            icon: Icons.edit_note_rounded,
            title: loc.translate('manual_entry'),
            subtitle: loc.translate('manual_entry_desc'),
            onTap: onManualTap,
          ),
          SizedBox(height: 15.h),
          SelectionTile(
            icon: Icons.map_rounded,
            title: loc.translate('map_entry'),
            subtitle: loc.translate('map_entry_desc'),
            onTap: onMapTap,
          ),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}

class SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SelectionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 20.w,
        backgroundColor: AppColors.primaryColor.withOpacity(0.1),
        child: Icon(icon, color: AppColors.primaryColor, size: 24.w),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.w),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
