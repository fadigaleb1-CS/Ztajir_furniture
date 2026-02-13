import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/presentation/view_model/category_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/discounted_products_by_category_view.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

import 'package:ztajir_furniture/core/constants/api_constants.dart';

class FlashSaleBanner extends StatefulWidget {
  const FlashSaleBanner({super.key});

  @override
  State<FlashSaleBanner> createState() => _FlashSaleBannerState();
}

class _FlashSaleBannerState extends State<FlashSaleBanner>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  Timer? _autoRefreshTimer;
  int _currentStartIndex = 0;

  @override
  void initState() {
    super.initState();

    // Fade animation setup
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();

    // Fetch categories
    Future.microtask(() {
      if (!mounted) return;
      context.read<CategoryProvider>().fetchCategories();
    });

    // Auto-refresh every 2 minutes (120 seconds)
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _refreshCategories();
    });
  }

  void _refreshCategories() {
    final categoryProvider = context.read<CategoryProvider>();
    final totalCategories = categoryProvider.categories.length;

    if (totalCategories <= 4) return; // No need to rotate if 4 or less

    // Fade out, change index, fade in
    _fadeController.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentStartIndex = (_currentStartIndex + 4) % totalCategories;
      });
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =================== Section Header ===================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              // Title
              Text(
                "العروض الحصرية",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // =================== 2x2 Grid Categories ===================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return _buildLoadingGrid();
              }

              if (categoryProvider.categories.isEmpty) {
                return _buildLoadingGrid();
              }

              // Get 4 categories starting from current index
              final categories = categoryProvider.categories;
              final displayCategories = _getDisplayCategories(categories);

              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // First Row (2 cards)
                    Row(
                      children: [
                        Expanded(
                          child: displayCategories.isNotEmpty
                              ? _OfferCategoryCard(
                                  categoryName: displayCategories[0].name,
                                  imageUrl: _getCorrectImageUrl(
                                    displayCategories[0].image,
                                  ),
                                  onTap: () =>
                                      _navigateToCategory(displayCategories[0]),
                                )
                              : const SizedBox(),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: displayCategories.length > 1
                              ? _OfferCategoryCard(
                                  categoryName: displayCategories[1].name,
                                  imageUrl: _getCorrectImageUrl(
                                    displayCategories[1].image,
                                  ),
                                  onTap: () =>
                                      _navigateToCategory(displayCategories[1]),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    // Second Row (2 cards)
                    Row(
                      children: [
                        Expanded(
                          child: displayCategories.length > 2
                              ? _OfferCategoryCard(
                                  categoryName: displayCategories[2].name,
                                  imageUrl: _getCorrectImageUrl(
                                    displayCategories[2].image,
                                  ),
                                  onTap: () =>
                                      _navigateToCategory(displayCategories[2]),
                                )
                              : const SizedBox(),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: displayCategories.length > 3
                              ? _OfferCategoryCard(
                                  categoryName: displayCategories[3].name,
                                  imageUrl: _getCorrectImageUrl(
                                    displayCategories[3].image,
                                  ),
                                  onTap: () =>
                                      _navigateToCategory(displayCategories[3]),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<dynamic> _getDisplayCategories(List<dynamic> categories) {
    if (categories.isEmpty) return [];

    final totalCategories = categories.length;
    final List<dynamic> result = [];

    for (int i = 0; i < 4 && i < totalCategories; i++) {
      final index = (_currentStartIndex + i) % totalCategories;
      result.add(categories[index]);
    }

    return result;
  }

  void _navigateToCategory(dynamic category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscountedProductsByCategoryView(
          categoryId: category.id,
          categoryName: category.name,
          slug: category.slug,
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            SizedBox(width: 12.w),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildLoadingCard()),
            SizedBox(width: 12.w),
            Expanded(child: _buildLoadingCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return _OfferLoadingCard();
  }

  String _getCorrectImageUrl(String imagePath) {
    if (imagePath.isEmpty) {
      return 'https://via.placeholder.com/150';
    }
    if (imagePath.startsWith('http')) {
      return imagePath;
    }
    return '${ApiConstants.storageUrl}/$imagePath';
  }
}

// =================== Offer Category Card Widget ===================
class _OfferCategoryCard extends StatefulWidget {
  final String categoryName;
  final String imageUrl;
  final VoidCallback onTap;

  const _OfferCategoryCard({
    required this.categoryName,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_OfferCategoryCard> createState() => _OfferCategoryCardState();
}

class _OfferCategoryCardState extends State<_OfferCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 110.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(
                  alpha: _isPressed ? 0.25 : 0.12,
                ),
                blurRadius: _isPressed ? 16 : 12,
                offset: Offset(0, _isPressed ? 6 : 4),
                spreadRadius: _isPressed ? 1 : 0,
              ),
              BoxShadow(
                color: AppColors.blackColor.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.w),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ===== Background Image =====
                Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _FlashSaleShimmer();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.darkGreyColor.withValues(alpha: 0.2),
                      child: Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.darkGreyColor.withValues(alpha: 0.4),
                        size: 32.w,
                      ),
                    );
                  },
                ),

                // ===== Gradient Overlay =====
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.transparentColor,
                        AppColors.transparentColor,
                        AppColors.blackColor.withValues(alpha: 0.4),
                        AppColors.blackColor.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // ===== Category Name =====
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    child: Text(
                      widget.categoryName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: AppColors.blackColor.withValues(alpha: 0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Shimmer Loading for Flash Sale Images
class _FlashSaleShimmer extends StatefulWidget {
  const _FlashSaleShimmer();

  @override
  State<_FlashSaleShimmer> createState() => __FlashSaleShimmerState();
}

class __FlashSaleShimmerState extends State<_FlashSaleShimmer>
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
                Color(0xFFE0E0E0), // رمادي متوسط
                Color(0xFFF5F5F5), // رمادي فاتح
                Color(0xFFFFFFFF), // أبيض ناصع (لمعان)
                Color(0xFFF5F5F5), // رمادي فاتح
                Color(0xFFE0E0E0), // رمادي متوسط
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

// Offer Loading Card with Shimmer
class _OfferLoadingCard extends StatefulWidget {
  const _OfferLoadingCard();

  @override
  State<_OfferLoadingCard> createState() => __OfferLoadingCardState();
}

class __OfferLoadingCardState extends State<_OfferLoadingCard>
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
          height: 110.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFFFFFFF),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
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
