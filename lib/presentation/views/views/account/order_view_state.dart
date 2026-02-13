import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/utiles/snack_bar_helper.dart';
import 'package:ztajir_furniture/presentation/view_model/order_provider.dart';
import 'package:ztajir_furniture/presentation/view_model/cart_service.dart';
import 'package:ztajir_furniture/data/models/cart_item_model.dart';
import 'package:ztajir_furniture/presentation/views/views/account/order_details_view.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';
import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:ztajir_furniture/presentation/views/views/cart/cart_view.dart';
import 'package:intl/intl.dart';
import 'package:ztajir_furniture/core/utiles/price_formatter.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<_OrderTab> _tabs = [
    _OrderTab(label: 'الكل', statuses: null),
    _OrderTab(label: 'قيد الانتظار', statuses: ['pending', 'processing']),
    _OrderTab(label: 'تم الشحن', statuses: ['shipped']),
    _OrderTab(label: 'تم التوصيل', statuses: ['delivered', 'completed']),
    _OrderTab(label: 'ملغي', statuses: ['cancelled']),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<OrderModel> _filterOrders(
    List<OrderModel> orders,
    List<String>? statuses,
  ) {
    if (statuses == null) return orders;
    return orders
        .where((order) => statuses.contains(order.status.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.whiteColor,
            size: 20.w,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.translate('my_orders_title'),
          style: TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.whiteColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15.w),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.center,
              indicator: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12.w),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.whiteColor.withOpacity(0.8),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w900,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: _tabs
                  .map(
                    (tab) => Tab(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Text(tab.label),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.w,
                    color: AppColors.redColor,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "حدث خطأ: ${orderProvider.error ?? 'غير معروف'}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.redColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => orderProvider.fetchOrders(),
                    child: const Text("إعادة المحاولة"),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              final filteredOrders = _filterOrders(
                orderProvider.orders,
                tab.statuses,
              );

              if (filteredOrders.isEmpty) {
                return _buildEmptyState(tab.label);
              }

              return RefreshIndicator(
                onRefresh: () => orderProvider.fetchOrders(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(context, order);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80.w,
            color: AppColors.darkGreyColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            "لا توجد طلبات في قسم $category",
            style: TextStyle(fontSize: 16.sp, color: AppColors.darkGreyColor),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final statusInfo = _getOrderStatus(context, order.status);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsView(orderData: order),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withOpacity(0.04),
              blurRadius: 20.w,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(18.w),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.w),
                    child: firstItem?.productImage != null
                        ? Image.network(
                            firstItem!.productImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.shopping_bag, color: Colors.grey),
                  ),
                ),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.orderCode,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.darkGreyColor,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusInfo.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.w),
                            ),
                            child: Text(
                              statusInfo.text,
                              style: TextStyle(
                                color: statusInfo.color,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        firstItem?.productName ?? "منتجات متنوعة",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (order.items.length > 1)
                        Text(
                          "+ ${order.items.length - 1} منتجات أخرى",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              "${formatPrice(order.total)} ${order.currency}",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            DateFormat('yyyy-MM-dd').format(order.createdAt),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.darkGreyColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (order.canCancel) ...[
              Divider(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _confirmCancel(context, order.orderNumber),
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: AppColors.redColor,
                      size: 18.w,
                    ),
                    label: Text(
                      "إلغاء الطلب",
                      style: TextStyle(
                        color: AppColors.redColor,
                        fontSize: 12.sp,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.redColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.w),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (order.status.toLowerCase() == 'cancelled') ...[
              Divider(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _reorderItems(context, order),
                      icon: Icon(
                        Icons.refresh,
                        color: AppColors.primaryColor,
                        size: 18.w,
                      ),
                      label: Text(
                        "إعادة الطلب",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 12.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _hideOrder(context, order.id),
                      icon: Icon(
                        Icons.visibility_off_outlined,
                        color: AppColors.darkGreyColor,
                        size: 18.w,
                      ),
                      label: Text(
                        "إخفاء",
                        style: TextStyle(
                          color: AppColors.darkGreyColor,
                          fontSize: 12.sp,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.darkGreyColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.w),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context, String orderNumber) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الإلغاء"),
        content: const Text("هل أنت متأكد من رغبتك في إلغاء هذا الطلب؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("تراجع"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelOrder(context, orderNumber);
            },
            child: const Text(
              "نعم، إلغاء",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, String orderNumber) async {
    try {
      await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).cancelOrder(orderNumber);

      if (context.mounted) {
        SnackBarHelper.show(
          context: context,
          message: "تم إلغاء الطلب بنجاح",
          backgroundColor: AppColors.greenColor,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.show(
          context: context,
          message: "فشل في إلغاء الطلب: $e",
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  void _reorderItems(BuildContext context, OrderModel order) async {
    try {
      final cartService = Provider.of<CartService>(context, listen: false);

      for (var item in order.items) {
        final cartItem = CartItem(
          id: item.productId.toString(),
          productId: item.productId.toString(),
          title: item.productName,
          price: item.price,
          image: item.productImage ?? '',
          quantity: item.quantity,
        );
        await cartService.addItem(cartItem);
      }

      if (context.mounted) {
        SnackBarHelper.show(
          context: context,
          message: "تمت إضافة المنتجات للسلة",
          backgroundColor: AppColors.greenColor,
          action: SnackBarAction(
            label: "عرض السلة",
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarHelper.show(
          context: context,
          message: "فشل في إضافة المنتجات: $e",
          backgroundColor: AppColors.redColor,
        );
      }
    }
  }

  Future<void> _hideOrder(BuildContext context, int orderId) async {
    await Provider.of<OrderProvider>(context, listen: false).hideOrder(orderId);
    if (context.mounted) {
      SnackBarHelper.show(
        context: context,
        message: "تم إخفاء الطلب",
        backgroundColor: Colors.grey,
      );
    }
  }

  _StatusInfo _getOrderStatus(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return _StatusInfo("قيد الانتظار", Colors.orange);
      case 'processing':
        return _StatusInfo("قيد التنفيذ", Colors.blue);
      case 'shipped':
        return _StatusInfo("تم الشحن", Colors.purple);
      case 'delivered':
      case 'completed':
        return _StatusInfo("تم التوصيل", Colors.green);
      case 'cancelled':
        return _StatusInfo("ملغي", Colors.red);
      default:
        return _StatusInfo(status, Colors.grey);
    }
  }
}

class _StatusInfo {
  final String text;
  final Color color;

  _StatusInfo(this.text, this.color);
}

class _OrderTab {
  final String label;
  final List<String>? statuses;

  const _OrderTab({required this.label, this.statuses});
}
