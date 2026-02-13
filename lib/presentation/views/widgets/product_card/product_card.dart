// presentation/widgets/product_card/product_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/views/product_detail.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';
import 'package:ztajir_furniture/presentation/view_model/product_details_service.dart'; // Added import

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onFavoriteToggled;
  final bool
  showNewBadge; // إظهار شارة "جديد" - يتم تفعيلها فقط في قسم "وصل حديثاً"

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteToggled,
    this.showNewBadge = false,
  });

  static const double aspectRatioValue = 0.70;

  static double calculateAspectRatio(BuildContext context) {
    //  (Screen Width - Padding) / 2
    // Assuming approx 40-50px total horizontal padding in grids
    final double cardWidth = (MediaQuery.of(context).size.width - 40) / 2;

    // Image Height: width / (1/0.70) = width * 0.70
    final double imageHeight = cardWidth * 0.70;

    // Estimated Text Content Height (Title + Desc + Price + Padding)
    // 16 (pad) + 20 (title) + 18 (desc) + 25 (price) + 20 (discount/spacing) = ~100-110
    const double textHeight = 125.0;

    return cardWidth / (imageHeight + textHeight);
  }

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late String _displayDescription;
  bool _isLoadingDesc = false;

  @override
  void initState() {
    super.initState();
    _displayDescription = widget.product.describtion;

    // إذا كان الوصف فارغاً، نحاول جلبه من API التفاصيل
    if (_displayDescription.isEmpty) {
      _fetchDescription();
    }
  }

  Future<void> _fetchDescription() async {
    if (mounted) {
      setState(() {
        _isLoadingDesc = true;
      });
    }

    try {
      final identifier = widget.product.slug ?? widget.product.id.toString();
      final details = await ProductDetailsService().getProductDetails(
        identifier,
      );
      if (mounted) {
        setState(() {
          _displayDescription = details.describtion;
          _isLoadingDesc = false;
        });
      }
    } catch (e) {
      debugPrint('Err fetching description for card: $e');
      if (mounted) {
        setState(() {
          _isLoadingDesc = false;
        });
      }
    }
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: widget.product),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      final loc = AppLocalizations.of(context)!;
      final navigator = Navigator.of(context);

      SnackBarHelper.show(
        context: context,
        message: loc.translate('login_required_favorite'),
        backgroundColor: AppColors.redColor,
        action: SnackBarAction(
          label: loc.translate('login'),
          textColor: AppColors.whiteColor,
          onPressed: () {
            navigator.pushNamed(AppRoutes.loginScreen);
          },
        ),
      );
      return;
    }

    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    favoriteProvider.toggleFavorite(widget.product);
    if (widget.onFavoriteToggled != null) widget.onFavoriteToggled!();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favoriteProvider, child) {
        final isFavorite = favoriteProvider.isFavorite(
          widget.product.id.toString(),
        );

        return InkWell(
          onTap: () => _navigateToDetail(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(16.w),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(
                    0.08,
                  ), // ظل أسود خفيف جداً
                  blurRadius: 4.w, // تمويه قليل لتقليل الانتشار للجوانب
                  offset: Offset(0, 4.h), // إزاحة للأسفل فقط
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.w),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1 / ProductCard.aspectRatioValue,
                        child: Builder(
                          builder: (context) {
                            // التحقق مما إذا كان الرابط ويب (يبدأ بـ http أو https)
                            if (widget.product.image.startsWith('http') ||
                                widget.product.image.startsWith('https')) {
                              // التحقق من أن الرابط ليس صفحة ويب (تجاهل الروابط المعروفة بأنها خاطئة)
                              if (widget.product.image.contains(
                                    'furniture-nor.com',
                                  ) &&
                                  !widget.product.image.contains(
                                    RegExp(
                                      r'\.(jpg|jpeg|png|webp|gif)',
                                      caseSensitive: false,
                                    ),
                                  )) {
                                return Container(
                                  color: AppColors.darkGreyColor,
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: AppColors.darkGreyColor,
                                  ),
                                );
                              }

                              return Image.network(
                                widget.product.image,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.darkGreyColor,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: AppColors.darkGreyColor,
                                    ),
                                  );
                                },
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      // Shimmer effect while loading
                                      return const _ShimmerLoading();
                                    },
                              );
                            }

                            // إذا لم يكن رابط شبكة، نعرض صورة تالفة (تجاوز الصور المحلية كما طلبت)
                            return Container(
                              color: AppColors.darkGreyColor,
                              child: const Icon(
                                Icons.broken_image,
                                color: AppColors.darkGreyColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // شارة جديد + زر المفضلة في صف واحد
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      right: 8.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // زر المفضلة (يسار في العربية، يمين في الإنجليزية)
                          InkWell(
                            onTap: () => _toggleFavorite(context),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.redColor
                                    : AppColors.primaryColor,
                                size: 18.w,
                              ),
                            ),
                          ),

                          // شارة "جديد" (يمين في العربية، يسار في الإنجليزية)
                          if (widget.showNewBadge && widget.product.isNew)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.greenColor,
                                    AppColors.greenColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6.w),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.translate('new'),
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),

                // Product Details
                Padding(
                  padding: EdgeInsets.only(
                    top: 6.h,
                    left: 8.w,
                    right: 8.w,
                    bottom: 4.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان + التقييم في صف واحد
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // العنوان
                          Expanded(
                            child: Text(
                              widget.product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                          // التقييم
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 12.w,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                widget.product.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGreyColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: 3.h),

                      // عرض الوصف أو Skeleton إذا كان يتم التحميل
                      if (_isLoadingDesc)
                        Container(
                          height: 12.h,
                          width: 100.w,
                          margin: EdgeInsets.only(bottom: 2.h),
                          color: AppColors.darkGreyColor,
                        )
                      else if (_displayDescription.isNotEmpty)
                        Text(
                          _displayDescription,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12.sp,
                            color: AppColors.textColor.withOpacity(0.7),
                          ),
                        )
                      else
                        // مساحة فارغة صغيرة حتى لو لم يكن هناك وصف للحفاظ على التناسق
                        SizedBox(
                          height: 14.h,
                        ), // Approximate height of 1 line text

                      SizedBox(height: 6.h),

                      // Price + Cart Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.product.oldPrice != null) ...[
                                  Text(
                                    "${formatPrice(widget.product.oldPrice!)} ${widget.product.currency ?? 'YER'}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: AppColors.darkGreyColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                ],
                                Text(
                                  "${formatPrice(widget.product.price)} ${widget.product.currency ?? 'YER'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Add to cart button
                          InkWell(
                            onTap: () async {
                              var loc = AppLocalizations.of(context)!;

                              if (!widget.product.inStock) {
                                SnackBarHelper.show(
                                  context: context,
                                  message: loc.translate('item_out_of_stock'),
                                  backgroundColor: AppColors.redColor,
                                );
                                return;
                              }

                              final newItem = CartItem(
                                id: widget.product.id.toString(),
                                productId: widget.product.id.toString(),
                                title: widget.product.title,
                                price: widget.product.price,
                                image: widget.product.image,
                                quantity: 1,
                                currency: widget.product.currency ?? 'YER',
                              );
                              try {
                                await CartService().addItem(newItem);
                                if (context.mounted) {
                                  SnackBarHelper.show(
                                    context: context,
                                    message: loc.translate(
                                      'added_to_cart_message',
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  SnackBarHelper.show(
                                    context: context,
                                    message: "فشل الإضافة: $e",
                                    backgroundColor: AppColors.redColor,
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: widget.product.inStock
                                    ? AppColors.primaryColor
                                    : AppColors.darkGreyColor,
                                borderRadius: BorderRadius.circular(10.w),
                              ),
                              child: Icon(
                                Icons.add_shopping_cart,
                                color: AppColors.whiteColor,
                                size: 18.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Shimmer Loading Widget for Images
class _ShimmerLoading extends StatefulWidget {
  const _ShimmerLoading();

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFDDDDDD), // رمادي متوسط
                Color(0xFFEEEEEE), // رمادي فاتح
                Color(0xFFFFFFFF), // أبيض ناصع (لمعان)
                Color(0xFFEEEEEE), // رمادي فاتح
                Color(0xFFDDDDDD), // رمادي متوسط
              ],
              stops: [
                0.0,
                (_animation.value * 0.5 - 0.25).clamp(0.0, 1.0),
                (_animation.value * 0.5).clamp(0.0, 1.0),
                (_animation.value * 0.5 + 0.25).clamp(0.0, 1.0),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
