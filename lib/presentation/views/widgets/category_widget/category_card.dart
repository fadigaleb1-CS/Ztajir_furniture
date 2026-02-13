import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // الألوان المقترحة (يمكنك استبدالها بألوان البراند الخاص بك)
    final activeColor = AppColors.primaryColor; // لون بني خشبي مناسب للأثاث
    final inactiveColor = AppColors.darkGreyColor; // رمادي فاتح جداً

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // نعومة في التحويل
        curve: Curves.easeInOut,
        width: 80.w, // عرض ثابت للكارد
        decoration: BoxDecoration(
          color: isSelected ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(50.w), // شكل كبسولة (Pill Shape)
          border: isSelected
              ? Border.all(color: activeColor, width: 2.w)
              : Border.all(color: AppColors.transparentColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(
                0.08,
              ), // ظل أسود خفيف جداً
              blurRadius: 3.w, // تمويه قليل لتقليل الانتشار للجوانب
              offset: Offset(0, 3.h), // إزاحة للأسفل فقط
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // دائرة الصورة
            Container(
              padding: EdgeInsets.all(3.w), // حافة بيضاء حول الصورة
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 28.w,
                backgroundColor: AppColors.darkGreyColor,
                backgroundImage: category.image.trim().isNotEmpty
                    ? NetworkImage(_getCorrectImageUrl(category.image.trim()))
                    : null,
                onBackgroundImageError: category.image.trim().isNotEmpty
                    ? (exception, stackTrace) {
                        debugPrint('Failed to load category image: $exception');
                      }
                    : null,
                child: category.image.trim().isEmpty
                    ? Icon(
                        Icons.weekend_outlined,
                        color: AppColors.whiteColor,
                        size: 28.w,
                      )
                    : null,
              ),
            ),

            SizedBox(height: 8.h),

            // النص
            Text(
              category.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.whiteColor
                    : AppColors.darkGreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// دالة مساعدة لتصحيح رابط الصورة
  /// إذا كان الرابط لا يحتوي على http، نقوم بإضافة الدومين الخاص بالتخزين
  String _getCorrectImageUrl(String imagePath) {
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${ApiConstants.storageUrl}/$imagePath';
  }
}
