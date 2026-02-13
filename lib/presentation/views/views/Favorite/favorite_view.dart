import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/body_message_empty.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(appBarName: loc.translate('favorite_title')),
      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteItems = favoriteProvider.favoriteProducts;

          if (favoriteItems.isEmpty) {
            return BodyMessage(messageEmpty: loc.translate('no_favorites'));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: 16.h)),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: ProductGrid(products: favoriteItems, isSliver: true),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          );
        },
      ),
    );
  }
}
