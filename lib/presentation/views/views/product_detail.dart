import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/presentation/view_model/favorite_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/product_details_service.dart';
import 'package:ztajir_furniture/presentation/views/widgets/payment_bottom_sheet.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_sliver_app_bar.dart';

import 'package:ztajir_furniture/presentation/views/widgets/text_sections.dart';
import 'package:ztajir_furniture/presentation/views/widgets/product_card/product_grid.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel _product;
  bool _isFavorite = false;
  int _quantity = 1;
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _isFavorite = widget.product.isFavorite;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final favoriteProvider = context.read<FavoriteProvider>();
      setState(() {
        _isFavorite = favoriteProvider.isFavorite(widget.product.id.toString());
      });
      _fetchProductDetails();
      _fetchRelatedProducts();
    });
  }

  Future<void> _fetchProductDetails() async {
    try {
      // Use slug if available, otherwise ID
      final identifier = _product.slug ?? _product.id.toString();
      final fullDetails = await ProductDetailsService().getProductDetails(
        identifier,
      );
      setState(() {
        _product = fullDetails;
        _isLoadingDetails = false;
        // Re-check favorite status with potentially updated ID (if changed, though unlikely)
        _isFavorite = context.read<FavoriteProvider>().isFavorite(
          _product.id.toString(),
        );
      });
    } catch (e) {
      debugPrint('Error fetching details: $e');
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _addToCart() async {
    if (!_product.inStock || _product.stockQuantity < _quantity) {
      var loc = AppLocalizations.of(context)!;
      SnackBarHelper.show(
        context: context,
        message: loc.translate('item_out_of_stock'),
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    final newItem = CartItem(
      id: _product.id.toString(),
      productId: _product.id.toString(),
      title: _product.title,
      price: _product.price,
      image: _product.image,
      quantity: _quantity,
      currency: _product.currency ?? 'YER',
    );

    try {
      await CartService().addItem(newItem);
      if (mounted) {
        SnackBarHelper.show(
          context: context,
          message: AppLocalizations.of(
            context,
          )!.translate('added_to_cart_message'),
          margin: EdgeInsets.only(bottom: 10.h, left: 16.w, right: 16.w),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.show(
          context: context,
          message: "فشل في إضافة العنصر: $e",
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  // دالة الشراء الفوري - تضيف للسلة ثم تفتح نافذة الدفع
  void _buyNow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) {
      var loc = AppLocalizations.of(context)!;
      final navigator = Navigator.of(context);
      SnackBarHelper.show(
        context: context,
        message: loc.translate('login_required_cart'),
        backgroundColor: AppColors.redColor,
        margin: EdgeInsets.only(bottom: 10.h, left: 16.w, right: 16.w),
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

    if (!_product.inStock || _product.stockQuantity < _quantity) {
      var loc = AppLocalizations.of(context)!;
      SnackBarHelper.show(
        context: context,
        message: loc.translate('item_out_of_stock'),
        backgroundColor: AppColors.redColor,
      );
      return;
    }

    // إظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cartService = Provider.of<CartService>(context, listen: false);

      // إنشاء عنصر السلة
      final cartItem = CartItem(
        id: _product.id.toString(),
        productId: _product.id.toString(),
        title: _product.title,
        price: _product.price,
        image: _product.image,
        quantity: _quantity,
        currency: _product.currency ?? 'YER',
      );

      // الإضافة للسلة وانتظار النتيجة
      await cartService.addItem(cartItem);

      // إخفاء مؤشر التحميل
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // بعد الإضافة للسلة، نستخدم بيانات السلة المحدثة لفتح الدفع
      if (mounted) {
        final currentCartItems = cartService.cartItems;
        final totalAmount = cartService.totalPrice;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.transparentColor,
          builder: (context) => PaymentBottomSheet(
            totalAmount: totalAmount,
            cartItems: currentCartItems, // نرسل عناصر السلة الفعلية
            subTotal: cartService.subTotal,
            discount: cartService.discountAmount,
            couponCode: cartService.appliedCoupon?.code,
            clearCartOnSuccess: true, // نمسح السلة بعد الدفع الناجح
          ),
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل في حال الخطأ
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        SnackBarHelper.show(
          context: context,
          message: "فشل في تجهيز الطلب: $e",
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  Widget _buildProductHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_product.brandName != null && _product.brandName!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.w),
                  ),
                  child: Text(
                    _product.brandName!,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18.w),
                  SizedBox(width: 4.w),
                  Text(
                    _product.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            _product.title,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textColor,
            ),
          ),

          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${formatPrice(_product.price)} ${_product.currency ?? 'YER'}",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 24.sp,
                ),
              ),
              SizedBox(width: 8.w),
              if (_product.oldPrice != null)
                Text(
                  "${formatPrice(_product.oldPrice!)} ${_product.currency ?? 'YER'}",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.redColor, // Changed to red
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),
          // حالة التوفر بتصميم بسيط
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: _product.inStock
                      ? AppColors.primaryColor.withOpacity(0.1)
                      : AppColors.redColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _product.inStock ? Icons.check : Icons.close,
                  color: _product.inStock
                      ? AppColors.primaryColor
                      : AppColors.redColor,
                  size: 14.w,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                _product.inStock
                    ? (AppLocalizations.of(context)!.translate('in_stock'))
                    : (AppLocalizations.of(context)!.translate('out_of_stock')),
                style: TextStyle(
                  color: _product.inStock
                      ? AppColors.primaryColor
                      : AppColors.redColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              if (_product.inStock) ...[
                SizedBox(width: 5.w),
                Text(
                  "(${_product.stockQuantity})",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.translate('description_title'),
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _product.describtion,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.5,
              color: AppColors.darkGreyColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(AppLocalizations loc) {
    if (_product.attributes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextSections(textSection: loc.translate('specifications_title')),
            SizedBox(height: 24.h), // Add spacing after title
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor, // خلفية بيضاء للبروز
                borderRadius: BorderRadius.circular(16.w),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.05),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _product.attributes.length,
                separatorBuilder: (context, index) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Divider(
                    height: 1,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                ),
                itemBuilder: (context, index) {
                  final item = _product.attributes[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان (يمين)
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // القيمة (يسار)
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.value,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      bottomNavigationBar: _buildBottomActionPanel(loc),
      body: CustomScrollView(
        slivers: [
          ProductSliverAppBar(
            product: _product,
            isFavorite: _isFavorite,
            onFavoriteToggle: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              context.read<FavoriteProvider>().toggleFavorite(_product);
            },
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 0),
              if (_isLoadingDetails)
                LinearProgressIndicator(color: AppColors.primaryColor),
              _buildProductHeader(),
              Divider(height: 1, color: Colors.grey[300]),
              _buildDescription(),
              Divider(height: 1, color: Colors.grey[300]),
              _buildSpecifications(loc),
              SizedBox(height: 24.h),
              Divider(height: 1, color: Colors.grey[300]),
            ]),
          ),

          // Related Products Section (As Slivers)
          if (_isLoadingRelated)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),

          if (!_isLoadingRelated && _relatedProducts.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                child: Column(
                  // Use Column to include Spacer
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h), // Spacing before section
                    TextSections(
                      textSection: loc.translate('related_products'),
                    ),
                    SizedBox(height: 24.h), // Spacing between title and grid
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: ProductGrid(products: _relatedProducts, isSliver: true),
            ),
          ],
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  // Related Products Logic
  List<ProductModel> _relatedProducts = [];
  bool _isLoadingRelated = false;

  Future<void> _fetchRelatedProducts() async {
    if (_product.categorySlug == null) return;

    setState(() {
      _isLoadingRelated = true;
    });

    try {
      final related = await ProductDetailsService().getRelatedProducts(
        _product.categorySlug!,
      );
      // Filter out the current product from related list
      final filtered = related.where((p) => p.id != _product.id).toList();

      if (mounted) {
        setState(() {
          _relatedProducts = filtered;
          _isLoadingRelated = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching related products: $e');
      if (mounted) {
        setState(() {
          _isLoadingRelated = false;
        });
      }
    }
  }

  Widget _buildBottomActionPanel(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withOpacity(0.1),
            blurRadius: 10.w,
            offset: Offset(0, -5.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عنوان الكمية في الأعلى
          Text(
            loc.translate('quantity_label'),
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          // صف الأزرار والرقم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Minus Button
              _buildQtyBtn(
                icon: Icons.remove,
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                active: _quantity > 1,
              ),
              // الرقم في الوسط
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  '$_quantity',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              // Plus Button
              _buildQtyBtn(
                icon: Icons.add,
                onTap: () {
                  if (_product.inStock && _quantity < _product.stockQuantity) {
                    setState(() => _quantity++);
                  } else if (!_product.inStock) {
                    // null op
                  } else {
                    // Limit reached
                    SnackBarHelper.show(
                      context: context,
                      message: 'Max quantity reached',
                      backgroundColor: Colors.orange,
                    );
                  }
                },
                isPlus: true,
                active: _product.inStock && _quantity < _product.stockQuantity,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // صف الأزرار (زر إضافة للسلة + زر اشتري الآن)
          Row(
            children: [
              // زر إضافة للسلة
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _product.inStock ? _addToCart : null,
                  icon: Icon(
                    Icons.add_shopping_cart,
                    color: _product.inStock
                        ? AppColors.primaryColor
                        : AppColors.darkGreyColor,
                    size: 20.w,
                  ),
                  label: Text(
                    loc.translate('add_to_cart'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _product.inStock
                          ? AppColors.primaryColor
                          : AppColors.darkGreyColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _product.inStock
                          ? AppColors.primaryColor
                          : AppColors.darkGreyColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // زر اشتري الآن
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _product.inStock ? _buyNow : null,
                  icon: Icon(
                    Icons.flash_on,
                    color: AppColors.whiteColor,
                    size: 20.w,
                  ),
                  label: Text(
                    _product.inStock
                        ? loc.translate('buy_now')
                        : loc.translate('out_of_stock'),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.whiteColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _product.inStock
                        ? AppColors.primaryColor
                        : AppColors.darkGreyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn({
    required IconData icon,
    required VoidCallback onTap,
    bool isPlus = false,
    bool active = true,
  }) {
    return Container(
      width: 35.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: isPlus
            ? (active ? AppColors.primaryColor : Colors.grey)
            : AppColors.primaryColor.withOpacity(active ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(8.w),
      ),
      alignment: Alignment.center,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18.w,
          color: isPlus
              ? AppColors.whiteColor
              : (active ? AppColors.primaryColor : AppColors.darkGreyColor),
        ),
        onPressed: active ? onTap : null,
      ),
    );
  }
}
