import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/view_model/branding_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/product_provider.dart';
import 'package:ztajir_furniture/presentation/views/views/flash_sale_banner.dart';
import 'package:ztajir_furniture/presentation/views/views/home/categories_section.dart';
import 'package:ztajir_furniture/presentation/views/widgets/icon_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/text_sections.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';
import 'package:ztajir_furniture/presentation/views/views/home/banner_slider.dart';
import 'package:ztajir_furniture/presentation/views/views/home/brands_section.dart';
import 'package:ztajir_furniture/presentation/views/views/home/notifications_view.dart';
import 'package:ztajir_furniture/presentation/views/views/home/section_products_view.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/data/mock/mock_data.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_card_skeleton.dart';
import 'package:ztajir_furniture/presentation/view_model/category_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/brand_provider.dart';
import 'package:ztajir_furniture/presentation/views/widgets/view_all.dart';
import 'package:ztajir_furniture/presentation/views/views/search/search_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double sizedBoxHeight = 24.h;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final productProvider = context.read<ProductProvider>();
      productProvider.fetchNewProducts();
      productProvider.fetchMostPopularProducts();
      productProvider.fetchSuggestedProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final bool isGuest = !authProvider.isAuthenticated;
    double expandedHeight = isGuest ? 0 : 100.h;
    var loc = AppLocalizations.of(context)!;

    context.watch<BrandingProvider>();

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, _) {
          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: () async {
              await Future.wait([
                context.read<ProductProvider>().fetchNewProducts(),
                context.read<ProductProvider>().fetchMostPopularProducts(),
                context.read<ProductProvider>().fetchSuggestedProducts(),
                context.read<CategoryProvider>().refreshCategories(),
                context.read<BrandProvider>().fetchBrands(),
                context.read<BrandingProvider>().fetchBranding(),
              ]);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.normal,
              ),
              slivers: [
                // ================== 1. الرأس المتحرك (App Bar) ==================
                SliverAppBar(
                  backgroundColor: AppColors.primaryColor,
                  expandedHeight: expandedHeight,
                  toolbarHeight: kToolbarHeight,
                  pinned: true,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(24.w),
                    ),
                  ),
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxHeight = expandedHeight;
                      final double minHeight =
                          kToolbarHeight + MediaQuery.of(context).padding.top;
                      double t = (maxHeight > minHeight)
                          ? ((constraints.biggest.height - minHeight) /
                                    (maxHeight - minHeight))
                                .clamp(0.0, 1.0)
                          : 0.0;

                      return Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (!authProvider.isAuthenticated) {
                            // ---------- Non-Authenticated State ----------
                            final logoUrl = brandingProvider.logos.logo;
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(24.w),
                                ),
                              ),
                              child: SafeArea(
                                bottom: false,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                  ),
                                  child: Row(
                                    children: [
                                      // شعار المتجر
                                      if (logoUrl != null && logoUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8.w,
                                          ),
                                          child: Image.network(
                                            logoUrl,
                                            width: 32.w,
                                            height: 32.w,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.store_rounded,
                                              size: 26.w,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.store_rounded,
                                          size: 26.w,
                                          color: AppColors.whiteColor,
                                        ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          brandingProvider
                                                  .branding
                                                  .brand
                                                  .displayName ??
                                              loc.translate('welcome_guest'),
                                          style: TextStyle(
                                            color: AppColors.whiteColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 17.sp,
                                            letterSpacing: 0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      TopIconButton(
                                        icon: Icons.search_rounded,
                                        size: 20.w,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SearchScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(width: 8.w),
                                      TopIconButton(
                                        icon: Icons.notifications_outlined,
                                        size: 20.w,
                                        badgeCount: 0,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const NotificationsView(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          // ---------- Authenticated State (Existing Logic) ----------
                          final double avatarRadius = 16.w + (8.w * t);
                          final double nameFontSize = 14.sp + (2.sp * t);
                          final bool showEmail = t >= 0.5;
                          final double iconSize = 20.w + (2.w * t);

                          final String? avatarUrl =
                              authProvider.user?.avatarUrl ??
                              MockData.currentUser.avatarUrl;
                          final String name =
                              authProvider.user?.name ??
                              MockData.currentUser.name;
                          final String email =
                              authProvider.user?.email ??
                              MockData.currentUser.email;

                          ImageProvider? profileImage;
                          if (avatarUrl != null && avatarUrl.isNotEmpty) {
                            if (avatarUrl.startsWith('http')) {
                              profileImage = NetworkImage(avatarUrl);
                            } else if (avatarUrl.startsWith('/') ||
                                avatarUrl.contains('\\') ||
                                avatarUrl.contains(':')) {
                              profileImage = FileImage(File(avatarUrl));
                            } else {
                              profileImage = AssetImage(avatarUrl);
                            }
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(24.w),
                              ),
                            ),
                            child: SafeArea(
                              bottom: false,
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 8.h + (6.h * t),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(2.w),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.whiteColor,
                                            AppColors.whiteColor.withOpacity(
                                              0.5,
                                            ),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: avatarRadius,
                                        backgroundColor: AppColors.whiteColor,
                                        child: CircleAvatar(
                                          radius: avatarRadius - 2.w,
                                          backgroundColor: AppColors
                                              .primaryColor
                                              .withOpacity(0.1),
                                          backgroundImage: profileImage,
                                          child: profileImage == null
                                              ? Icon(
                                                  Icons.person,
                                                  size: avatarRadius,
                                                  color: AppColors
                                                      .primaryColor, // Changed to primary color for contrast on white bg
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: nameFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.whiteColor,
                                              height: 1.2,
                                            ),
                                          ),
                                          AnimatedOpacity(
                                            duration: const Duration(
                                              milliseconds: 200,
                                            ),
                                            opacity: showEmail ? 1 : 0,
                                            child: showEmail
                                                ? Padding(
                                                    padding: EdgeInsets.only(
                                                      top: 2.h,
                                                    ),
                                                    child: Text(
                                                      email,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: AppColors
                                                            .whiteColor
                                                            .withOpacity(0.7),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    TopIconButton(
                                      icon: Icons.notifications_outlined,
                                      size: iconSize,
                                      badgeCount: 2, // 🔥 عدد الإشعارات الوهمي
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const NotificationsView(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),

                // ================== 2. المحتوى الثابت (SliverToBoxAdapter) ==================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BannerSlider(),
                        SizedBox(height: sizedBoxHeight),
                        const BrandsSection(),
                        SizedBox(height: sizedBoxHeight),
                        const CategoriesSection(),
                        SizedBox(height: sizedBoxHeight),
                      ],
                    ),
                  ),
                ),

                // ================== (جديد) 3. وصل حديثاً (New Arrivals) ==================
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextSections(
                              textSection: loc.translate('new_arrivals'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SectionProductsView(
                                      title: loc.translate('new_arrivals'),
                                      products: productProvider.newProducts,
                                    ),
                                  ),
                                );
                              },
                              child: const ViewAll(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizedBoxHeight),
                      SizedBox(
                        height: 250.h,
                        child: Builder(
                          builder: (context) {
                            // Show skeleton while loading OR if empty (might be loading)
                            if (productProvider.isLoading ||
                                productProvider.newProducts.isEmpty) {
                              return _buildHorizontalSkeletonList();
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              itemCount: productProvider.newProducts.length,
                              itemBuilder: (context, index) {
                                final product =
                                    productProvider.newProducts[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: SizedBox(
                                    width: 170.w,
                                    child: ProductCard(
                                      product: product,
                                      showNewBadge: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),

                // ================== (جديد) 5. عروض وتخفيضات (Flash Sales) ==================
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: const FlashSaleBanner(),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: sizedBoxHeight)),

                // ================== 6. قسم المنتجات الأكثر مبيعاً (Best Selling) ==================
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextSections(
                              textSection: loc.translate('best_selling'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SectionProductsView(
                                      title: loc.translate('best_selling'),
                                      products:
                                          productProvider.suggestedProducts,
                                    ),
                                  ),
                                );
                              },
                              child: const ViewAll(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizedBoxHeight),
                      SizedBox(
                        height: 250.h,
                        child: Builder(
                          builder: (context) {
                            // Show skeleton cards while loading or empty
                            if (productProvider.isLoading ||
                                productProvider.suggestedProducts.isEmpty) {
                              return _buildHorizontalSkeletonList();
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              itemCount:
                                  productProvider.suggestedProducts.length,
                              itemBuilder: (context, index) {
                                final product =
                                    productProvider.suggestedProducts[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: SizedBox(
                                    width: 170.w,
                                    child: ProductCard(product: product),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: sizedBoxHeight),
                    ],
                  ),
                ),

                // ================== 7. الأشهر (Most Popular / Featured) ==================
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextSections(
                              textSection: loc.translate('most_popular'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SectionProductsView(
                                      title: loc.translate('most_popular'),
                                      products:
                                          productProvider.mostPopularProducts,
                                    ),
                                  ),
                                );
                              },
                              child: const ViewAll(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sizedBoxHeight),
                      SizedBox(
                        height: 250.h,
                        child: Builder(
                          builder: (context) {
                            // Show skeleton cards while loading or empty
                            if (productProvider.isLoading ||
                                productProvider.mostPopularProducts.isEmpty) {
                              return _buildHorizontalSkeletonList();
                            }

                            return ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
                              itemCount:
                                  productProvider.mostPopularProducts.length,
                              itemBuilder: (context, index) {
                                final product =
                                    productProvider.mostPopularProducts[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: SizedBox(
                                    width: 170.w,
                                    child: ProductCard(product: product),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: sizedBoxHeight),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 26.h)),

                // ================== 8. المقترحات (الشبكة في الأسفل) ==================
                // Using main products list as suggestions for now
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: TextSections(
                      textSection: loc.translate('suggestions'),
                    ),
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: sizedBoxHeight)),

                if (productProvider.isLoading ||
                    productProvider.suggestedProducts.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: SizedBox(
                              height: 240.h,
                              child: Row(
                                children: [
                                  const Expanded(child: ProductCardSkeleton()),
                                  SizedBox(width: 16.w),
                                  const Expanded(child: ProductCardSkeleton()),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: 4, // إظهار 4 صفوف من الهياكل
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    sliver: ProductGrid(
                      products: productProvider.suggestedProducts,
                      isSliver: true,
                    ),
                  ),
                // مسافة إضافية لإظهار آخر كارد بشكل كامل فوق الـ NavigationBar
                SliverToBoxAdapter(child: SizedBox(height: 80.h)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper method to build horizontal skeleton list
  Widget _buildHorizontalSkeletonList() {
    return SizedBox(
      height: 250.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: const ProductCardSkeleton(),
          );
        },
      ),
    );
  }
}
