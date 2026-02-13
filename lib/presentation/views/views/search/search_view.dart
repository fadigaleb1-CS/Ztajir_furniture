import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/search_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/search/search_input_field.dart';
import 'package:ztajir_furniture/presentation/views/views/search/search_results.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SearchProvider(),
      child: Scaffold(
        backgroundColor: AppColors.secondaryColor,
        appBar: StaticAppBar(
          appBarName: AppLocalizations.of(context)!.translate('search_title'),
        ),
        body: Column(
          children: [
            const SearchInputField(),
            Expanded(child: SearchResultsView()),
          ],
        ),
      ),
    );
  }
}
