import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/search_provider.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/views/search/filter_sheet.dart';

class SearchInputField extends StatefulWidget {
  const SearchInputField({super.key});

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SearchProvider>(context, listen: false);
    _controller = TextEditingController(text: provider.currentQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchProvider>(
      builder: (context, provider, child) {
        if (provider.currentQuery.isEmpty && _controller.text.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _controller.clear();
          });
        }

        return Padding(
          padding: EdgeInsets.only(
            top: 8.0.h,
            left: 12.0.w,
            right: 12.0.w,
            bottom: 8.0.h,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: AppColors.textColor, fontSize: 16.sp),
                  onChanged: (query) {
                    provider.updateSearchQuery(query);
                  },
                  textInputAction: TextInputAction.search,
                  onSubmitted: (query) {
                    provider.updateSearchQuery(query);
                    // Dismiss keyboard
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(
                      context,
                    )!.translate('search_hint'),
                    hintStyle: TextStyle(
                      color: AppColors.darkGreyColor.withOpacity(0.7),
                    ),
                    filled: true,
                    fillColor: AppColors.whiteColor,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.primaryColor,
                      size: 24.w,
                    ),
                    suffixIcon: provider.currentQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              _controller.clear();
                              provider.clearSearch();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.w),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 1.5.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.w),
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2.0.w,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 18.w,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // زر الفلترة
              Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15.w),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 1.5.w,
                  ),
                ),
                child: IconButton(
                  icon: Icon(Icons.tune_rounded, color: AppColors.primaryColor),
                  onPressed: () {
                    final searchProvider = Provider.of<SearchProvider>(
                      context,
                      listen: false,
                    );
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.transparentColor,
                      builder: (context) => ChangeNotifierProvider.value(
                        value: searchProvider,
                        child: const FilterBottomSheet(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
