import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/presentation/view_model/order_provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/data/models/card_model.dart';

import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/presentation/view_model/payment_provider.dart';
import 'package:ztajir_furniture/data/models/address_model.dart';
import 'package:ztajir_furniture/presentation/views/views/account/address/address_view.dart';
import 'package:ztajir_furniture/presentation/view_model/auth_provider.dart';

import 'package:ztajir_furniture/presentation/views/views/account/payment/add_card_view.dart';
import 'package:ztajir_furniture/presentation/views/views/cart/order/order_confirmation_view.dart';
import 'package:ztajir_furniture/core/services/product_image_cache.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';

/// نافذة الدفع المشتركة - تُستخدم في السلة وصفحة التفاصيل
class PaymentBottomSheet extends StatefulWidget {
  final double totalAmount;
  final List<CartItem> cartItems;
  final double subTotal;
  final double discount;
  final String? couponCode;
  final bool clearCartOnSuccess; // لتحديد ما إذا كان يجب مسح السلة بعد الشراء

  const PaymentBottomSheet({
    super.key,
    required this.totalAmount,
    required this.cartItems,
    required this.subTotal,
    required this.discount,
    this.couponCode,
    this.clearCartOnSuccess = true,
  });

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String _selectedMethodId = 'credit_card';
  AddressModel? _selectedAddress;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Initialize with saved preference
    final provider = Provider.of<PaymentProvider>(context, listen: false);
    _selectedMethodId = provider.selectedMethodId;
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    final currency = widget.cartItems.isNotEmpty
        ? widget.cartItems.first.currency
        : 'YER';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 20.w, 20.w, 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.translate('payment_methods_title'),
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // عنوان التوصيل
          Text(
            loc.translate('delivery_address') ?? 'عنوان التوصيل',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: () async {
              // فتح نافذة اختيار العناوين
              // نمرر callback لاستلام العنوان المختار
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddressesScreen(
                    onSelect: (addr) {
                      setState(() {
                        _selectedAddress = addr;
                      });
                      // Navigator.pop handled inside AddressesScreen
                    },
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12.w),
                border: Border.all(
                  color: _selectedAddress != null
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: _selectedAddress != null
                        ? AppColors.primaryColor
                        : Colors.grey,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress?.title ??
                              loc.translate('select_delivery_address') ??
                              'اختر عنوان التوصيل',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: AppColors.textColor,
                          ),
                        ),
                        if (_selectedAddress != null)
                          Text(
                            _selectedAddress!.details,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.darkGreyColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14.w, color: Colors.grey),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // طرق الدفع
          Text(
            loc.translate('payment_methods_title'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 12.h),

          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, provider, child) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Global Methods
                      Text(
                        loc.translate('other_methods'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      _buildMethodTile(
                        id: 'cash',
                        title: loc.translate('cash_on_delivery'),
                      ),
                      SizedBox(height: 10.h),
                      _buildMethodTile(
                        id: 'jeeb',
                        title: loc.translate('jeeb'),
                        imagePath: 'images/wallets/1.png',
                      ),
                      SizedBox(height: 10.h),
                      _buildMethodTile(
                        id: 'mobile_money',
                        title: loc.translate('mobile_money'),
                        imagePath: 'images/wallets/2.jpeg',
                      ),
                      SizedBox(height: 10.h),
                      _buildMethodTile(
                        id: 'jawali',
                        title: loc.translate('jawali'),
                        imagePath: 'images/wallets/3.jpeg',
                      ),

                      SizedBox(height: 25.h),

                      // Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate('my_cards'),
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddCardScreen(),
                                ),
                              );
                              if (result != null && result is CardModel) {
                                if (!mounted) return;
                                provider.addCard(result);
                              }
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 16.w,
                              color: AppColors.primaryColor,
                            ),
                            label: Text(
                              loc.translate('add_new_card'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),

                      if (provider.cards.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Center(
                            child: Text(
                              loc.translate('no_payment_methods'),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.cards.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final card = provider.cards[index];
                            return _buildCardItem(card);
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 55.h,
              child: ElevatedButton(
                onPressed: () {
                  _handlePayment();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.w),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  '${loc.translate('pay_now')} ${formatPrice(widget.totalAmount)} $currency',
                  style: TextStyle(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile({
    required String id,
    required String title,
    String? imagePath,
  }) {
    bool isSelected = _selectedMethodId == id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethodId = id;
        });
      },
      borderRadius: BorderRadius.circular(12.w),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : AppColors.darkGreyColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 28.h,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(color: AppColors.darkGreyColor),
              ),
              child: imagePath != null
                  ? Image.asset(imagePath, fit: BoxFit.contain)
                  : Icon(
                      Icons.payments_outlined,
                      size: 20.w,
                      color: AppColors.darkGreyColor,
                    ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.blackColor,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: 22.w,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: AppColors.darkGreyColor,
                size: 22.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardItem(CardModel card) {
    bool isSelected = _selectedMethodId == card.id;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethodId = card.id;
        });
      },
      borderRadius: BorderRadius.circular(12.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12.w),
          boxShadow: [
            BoxShadow(
              color:
                  (isSelected
                          ? AppColors.primaryColor
                          : const Color(0xFF2C3E50))
                      .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.credit_card, color: AppColors.whiteColor, size: 24.w),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.holderName.isNotEmpty
                        ? card.holderName.toUpperCase()
                        : 'UNKNOWN',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  Text(
                    '**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}',
                    style: TextStyle(
                      color: AppColors.whiteColor,
                      fontFamily: 'Courier',
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.whiteColor, size: 20.w),
          ],
        ),
      ),
    );
  }

  void _handlePayment() async {
    var loc = AppLocalizations.of(context)!;

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        );
      },
    );

    if (_selectedAddress == null) {
      // Close the loading indicator if address is not selected
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.translate('select_delivery_address_error') ??
                'يرجى اختيار عنوان التوصيل لإتمام الطلب',
          ),
          backgroundColor: AppColors.redColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    if (widget.cartItems.isEmpty) {
      debugPrint('Generating order failed: Cart items list is empty!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No items to checkout.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Debug print
    debugPrint('🛒 Preparing checkout for ${widget.cartItems.length} items.');

    try {
      // تحديد طريقة الدفع للـ API (السيرفر يقبل cash فقط حالياً)
      const String apiPaymentMethod = 'cash';

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;

      // تجهيز قائمة المنتجات
      final items = widget.cartItems.map((item) {
        return {
          'product_id': int.tryParse(item.productId) ?? item.productId,
          'quantity': item.quantity,
          'unit_price': item.price,
          'subtotal': item.totalPrice,
        };
      }).toList();

      // البيانات بالشكل الصحيح (shipping_ prefix)
      final checkoutData = {
        'payment_method': apiPaymentMethod,
        'items': items,
        'products': items,

        // Shipping Fields
        'shipping_first_name': user?.firstName ?? 'Guest',
        'shipping_last_name': user?.lastName ?? 'User',
        'shipping_email': user?.email ?? 'guest@example.com',
        'shipping_phone': user?.phone ?? '0555555555',
        'shipping_address_1': _selectedAddress!.details,
        'shipping_address': _selectedAddress!.details,
        'shipping_city': 'Riyadh', // Default
        'shipping_country': 'Saudi Arabia',
        'shipping_zip': '12345',

        // Billing Fields (Mirroring shipping just in case)
        'billing_first_name': user?.firstName ?? 'Guest',
        'billing_last_name': user?.lastName ?? 'User',
        'billing_email': user?.email ?? 'guest@example.com',
        'billing_phone': user?.phone ?? '0555555555',
        'billing_address_1': _selectedAddress!.details,
        'billing_address': _selectedAddress!.details,
        'billing_city': 'Riyadh',
        'billing_country': 'Saudi Arabia',
        'billing_zip': '12345',
      };

      print('🛒 Checkout Payload (Trial 3): $checkoutData');

      // استدعاء API لإنشاء الطلب
      final newOrder = await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).checkout(checkoutData);

      // إغلاق مؤشر التحميل
      if (mounted) {
        Navigator.pop(context);
      }

      if (newOrder != null) {
        // حفظ صور المنتجات محلياً لاسترجاعها في شاشة الطلبات
        final imageMap = <String, String>{};
        for (var item in widget.cartItems) {
          if (item.image.isNotEmpty) {
            imageMap[item.productId] = item.image;
          }
        }
        if (imageMap.isNotEmpty) {
          ProductImageCache.cacheImages(imageMap);
        }

        // تحديث حالة السلة
        final provider = Provider.of<PaymentProvider>(context, listen: false);
        provider.selectMethod(_selectedMethodId); // حفظ طريقة الدفع المفضلة

        if (widget.clearCartOnSuccess) {
          Provider.of<CartService>(context, listen: false).clearCart();
        }

        // حفظ طريقة الدفع المختارة محلياً لاسترجاعها لاحقاً في شاشة الطلبات
        PaymentMethodCache.save(newOrder.orderNumber, _selectedMethodId);

        // تعيين اسم طريقة الدفع المختارة للعرض (السيرفر يرجع cash دائماً)
        final displayOrder = newOrder.copyWith(
          paymentMethod: _selectedMethodId,
        );

        // إغلاق BottomSheet والانتقال لصفحة التأكيد
        if (mounted) {
          Navigator.pop(context); // close bottom sheet
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OrderConfirmationView(orderData: displayOrder),
            ),
          );
        }
      }
    } catch (e) {
      print("❌ CHECKOUT PROCESS ERROR: $e"); // Debug Log requested by user

      // إغلاق مؤشر التحميل في حالة الخطأ
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${loc.translate('error_occurred')}: $e"),
            backgroundColor: AppColors.redColor,
          ),
        );
      }
    }
  }
}
