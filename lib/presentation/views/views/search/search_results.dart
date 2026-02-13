import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/presentation/view_model/search_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class SearchResultsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        // REMOVED 'Start typing' block to allow displaying filtered results with empty query

        if (provider.searchResults.isEmpty) {
          final isFilterActive =
              provider.minPrice != null ||
              provider.maxPrice != null ||
              provider.selectedSortOption != null;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded, // Changed icon
                  size: 80.w,
                  color: AppColors.darkGreyColor.withOpacity(0.4),
                ),
                SizedBox(height: 16.h),
                Text(
                  provider.currentQuery.isNotEmpty
                      ? '${AppLocalizations.of(context)!.translate('no_results_found')} "${provider.currentQuery}"'
                      : (isFilterActive
                            ? (AppLocalizations.of(
                                context,
                              )!.translate('no_results_filters'))
                            : (AppLocalizations.of(
                                context,
                              )!.translate('start_typing'))),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkGreyColor,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.only(
            left: 12.w,
            right: 12.w,
            top: 12.w,
            bottom: 80.h, // مسافة بين الكروت وشريط التصفح السفلي
          ),
          child: ProductGrid(products: provider.searchResults),
        );
      },
    );
  }
}
