import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/routes/app_route.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/presentation/views/widgets/primary_button.dart';
import 'package:ztajir_furniture/presentation/views/widgets/body_message_empty.dart';
import 'package:ztajir_furniture/presentation/views/widgets/cart_card/cart_item_card.dart';
import 'package:ztajir_furniture/presentation/views/widgets/cart_card/cart_price_row.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';
import 'package:ztajir_furniture/presentation/views/widgets/payment_bottom_sheet.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  double _calculateSubTotal(CartService service) {
    return service.subTotal;
  }

  double _calculateTotalPrice(CartService service) {
    return service.totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    // 💡 الحصول على نسخة الخدمة (مع الاستماع للتغيرات)
    final cartService = Provider.of<CartService>(context);
    final cartItems = cartService.cartItems;

    // final subTotal = _calculateSubTotal(cartService);
    // final totalPrice = _calculateTotalPrice(cartService);

    // Instead of using undefined getters, use the helper methods:
    double subTotal = _calculateSubTotal(cartService);
    double totalPrice = _calculateTotalPrice(cartService);
    var loc = AppLocalizations.of(context)!;

    // 💡 دوال التحكم بالإجراءات الآن تستدعي الخدمة مباشرة
    void _handleQuantityChange() {
      // بما أن Service.addItem/removeItem تستدعي notifyListeners، فإننا لا نحتاج لشيء هنا
    }

    void _removeItem(String id) {
      cartService.removeItem(id); // الخدمة ستتولى الإزالة و notifyListeners
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,

      // ================== 1. الرأس الثابت (App Bar) ==================
      appBar: StaticAppBar(appBarName: loc.translate('cart_title')),

      // ================== 2. جسم الصفحة (القائمة القابلة للتمرير) ==================
      body: cartItems.isEmpty
          ? BodyMessage(messageEmpty: loc.translate('cart_empty'))
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                // 💡 استخدام CartItemCard الحقيقي
                return CartItemCard(
                  item: item,
                  onQuantityChanged: _handleQuantityChange,
                  onRemove: _removeItem,
                );
              },
            ),

      // ================== 3. الشريط السفلي للإجمالي وزر الشراء (ثابت ومرفوع) ==================
      bottomNavigationBar: _buildCheckoutSection(
        context,
        cartService,
        subTotal,
        totalPrice,
      ),
    );
  }

  // ------------------------------------
  // دالة بناء قسم الإجمالي والدفع (معدلة لاستقبال القيم)
  // ------------------------------------
  Widget _buildCheckoutSection(
    BuildContext context,
    CartService cartService,
    double subTotal,
    double totalPrice,
  ) {
    var loc = AppLocalizations.of(context)!;
    final TextEditingController couponController = TextEditingController();
    final String currency = cartService.cartItems.isNotEmpty
        ? cartService.cartItems.first.currency
        : 'YER';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 16.h,
      ).copyWith(bottom: 99.h),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
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
          // --- Coupon Section ---
          if (cartService.appliedCoupon != null)
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(color: AppColors.greenColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer_rounded,
                        color: AppColors.greenColor,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${cartService.appliedCoupon!.code} (${(cartService.appliedCoupon!.discountPercentage * 100).toInt()}% Off)',
                        style: TextStyle(
                          color: AppColors.greenColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => cartService.removeCoupon(),
                    child: Icon(
                      Icons.close,
                      size: 20.w,
                      color: AppColors.darkGreyColor,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              margin: EdgeInsets.only(bottom: 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: couponController,
                      decoration: InputDecoration(
                        hintText: loc.translate('coupon_code'),
                        filled: true,
                        fillColor: const Color(
                          0xFFF5F5F5,
                        ), // لون خلفية فاتح ومناسب
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.w),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.local_offer_outlined,
                          color: Colors.grey, // لون أيقونة رمادي عادي
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () {
                      if (couponController.text.isNotEmpty) {
                        try {
                          cartService.applyCoupon(couponController.text);
                          SnackBarHelper.show(
                            context: context,
                            message: loc.translate('coupon_applied'),
                            backgroundColor: AppColors.greenColor,
                          );
                          couponController.clear();
                        } catch (e) {
                          SnackBarHelper.show(
                            context: context,
                            message: loc.translate('coupon_invalid'),
                            backgroundColor: AppColors.redColor,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.w),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                    ),
                    child: Text(
                      loc.translate('apply_coupon'),
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // --- Totals ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('subtotal'),
                style: TextStyle(
                  color: AppColors.darkGreyColor,
                  fontSize: 14.sp,
                ),
              ),
              Text(
                '${formatPrice(cartService.subTotal)} $currency',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          if (cartService.discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loc.translate('discount'),
                  style: TextStyle(
                    color: AppColors.greenColor,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  '- ${formatPrice(cartService.discountAmount)} $currency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),

          if (cartService.discountAmount > 0) SizedBox(height: 8.h),

          Divider(height: 20.h),

          CartPriceRow(
            title: loc.translate('checkout_total'),
            amount: totalPrice,
            currency: currency,
            color: AppColors.primaryColor,
            isBold: true,
          ),
          Divider(height: 20.h, color: AppColors.primaryColor),
          SizedBox(height: 16.h),
          // ... checkout button (remains same below)

          // زر إتمام الشراء
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: PrimaryButton(
              text: loc.translate('checkout_button'),
              onPressed: cartService.cartItems.isEmpty
                  ? null
                  : () {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      if (!authProvider.isAuthenticated) {
                        final navigator = Navigator.of(context);
                        SnackBarHelper.show(
                          context: context,
                          message: loc.translate('login_required_cart'),
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
                      _showPaymentSheet(context, totalPrice, cartService);
                    },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSheet(
    BuildContext context,
    double totalAmount,
    CartService cartService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparentColor,
      builder: (context) => PaymentBottomSheet(
        totalAmount: totalAmount,
        cartItems: List.from(cartService.cartItems),
        subTotal: cartService.subTotal,
        discount: cartService.discountAmount,
        couponCode: cartService.appliedCoupon?.code,
        clearCartOnSuccess: true, // امسح السلة بعد الشراء من السلة
      ),
    );
  }
}
