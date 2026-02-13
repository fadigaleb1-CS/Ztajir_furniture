import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/cart/cart_view.dart';
import 'package:ztajir_furniture/presentation/views/widgets/banner_widget/banner_dot.dart';

class ProductSliverAppBar extends StatefulWidget {
  final ProductModel product;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductSliverAppBar({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<ProductSliverAppBar> createState() => _ProductSliverAppBarState();
}

class _ProductSliverAppBarState extends State<ProductSliverAppBar> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Combine main image with gallery images, avoiding duplicates
    final Set<String> uniqueImages = {};
    if (widget.product.image.isNotEmpty) {
      uniqueImages.add(widget.product.image);
    }
    uniqueImages.addAll(widget.product.images);
    final images = uniqueImages.toList();

    return SliverAppBar(
      foregroundColor: AppColors.whiteColor,
      expandedHeight: 340.0.h, // Increased height for immersive experience
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: AppColors.transparentColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      backgroundColor: AppColors
          .primaryColor, // White when collapsed to hide content properly
      surfaceTintColor: AppColors.transparentColor,
      title: Text(
        widget.product.title,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Padding(
        padding: EdgeInsets.all(8.w),
        child: CircleAvatar(
          backgroundColor: AppColors.whiteColor.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            color: AppColors.primaryColor,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Image Slider
            CarouselSlider(
              options: CarouselOptions(
                height: 450.h, // Match expandedHeight
                viewportFraction: 1.0,
                enableInfiniteScroll: images.length > 1,
                autoPlay: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
              ),
              items: images.map((imgUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.darkGreyColor,
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.darkGreyColor,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }).toList(),
            ),

            // Gradient Overlay at bottom for smooth transition
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120.h, // Slightly taller for smoother fade
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.transparentColor,
                      AppColors.whiteColor.withOpacity(
                        0.0,
                      ), // Start transparent
                      AppColors.whiteColor.withOpacity(
                        0.8,
                      ), // Fade to semi-opaque
                      AppColors.whiteColor, // Solid white at very bottom
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0], // Smooth distribution
                  ),
                ),
              ),
            ),

            // Image Indicators
            if (images.length > 1)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: images.asMap().entries.map((entry) {
                    return BannerDot(
                      index: entry.key,
                      currentIndex: _currentImageIndex,
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        // Cart Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: CircleAvatar(
            backgroundColor: AppColors.whiteColor.withOpacity(0.9),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, size: 20),
              color: AppColors.primaryColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        ),
        // Favorite Button
        Padding(
          padding: EdgeInsets.only(right: 16.w, left: 4.w),
          child: CircleAvatar(
            backgroundColor: AppColors.whiteColor.withOpacity(0.9),
            child: IconButton(
              icon: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
              ),
              color: widget.isFavorite
                  ? AppColors.redColor
                  : AppColors.primaryColor,
              onPressed: () {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                if (!authProvider.isAuthenticated) {
                  var loc = AppLocalizations.of(context)!;
                  SnackBarHelper.show(
                    context: context,
                    message: loc.translate('login_required_favorite'),
                    backgroundColor: AppColors.redColor,
                  );
                  return;
                }
                widget.onFavoriteToggle();
              },
            ),
          ),
        ),
      ],
    );
  }
}
