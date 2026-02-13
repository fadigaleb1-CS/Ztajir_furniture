import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/view_model/search_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _currentRangeValues = const RangeValues(100, 500000);
  String? _selectedSort;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SearchProvider>(context, listen: false);
    _selectedSort = provider.selectedSortOption;
    if (provider.minPrice != null && provider.maxPrice != null) {
      _currentRangeValues = RangeValues(provider.minPrice!, provider.maxPrice!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.w),
          topRight: Radius.circular(30.w),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<SearchProvider>().clearFilters();
                  Navigator.pop(context);
                },
                child: Text(
                  'إعادة تعيين',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Price Range
          Text(
            'نطاق السعر (YER)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          RangeSlider(
            values: _currentRangeValues,
            min: 0,
            max: 500000,
            divisions: 50,
            activeColor: AppColors.primaryColor,
            inactiveColor: AppColors.darkGreyColor,
            labels: RangeLabels(
              _currentRangeValues.start.round().toString(),
              _currentRangeValues.end.round().toString(),
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_currentRangeValues.start.round()}'),
              Text('${_currentRangeValues.end.round()}'),
            ],
          ),

          SizedBox(height: 20.h),

          // Sort Options
          Text(
            'الترتيب حسب',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 10.h),
          Consumer<SearchProvider>(
            builder: (context, provider, _) {
              if (provider.sortOptions.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Wrap(
                spacing: 8.w,
                children: provider.sortOptions.entries.map((entry) {
                  return ChoiceChip(
                    label: Text(entry.value),
                    selected: _selectedSort == entry.key,
                    selectedColor: AppColors.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedSort == entry.key
                          ? AppColors.primaryColor
                          : AppColors.darkGreyColor,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedSort = selected ? entry.key : null;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),

          SizedBox(height: 30.h),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final provider = context.read<SearchProvider>();
                provider.setPriceRange(
                  _currentRangeValues.start,
                  _currentRangeValues.end,
                );
                provider.setSortOption(_selectedSort);
                provider.applyFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w),
                ),
              ),
              child: Text(
                'تطبيق الفلترة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
