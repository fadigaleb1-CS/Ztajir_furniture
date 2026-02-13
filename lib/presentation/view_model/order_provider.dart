import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:ztajir_furniture/data/repositories/order_repository.dart';
import 'package:ztajir_furniture/core/services/product_image_cache.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;
  Set<int> _hiddenOrderIds = {};

  static const String _hiddenOrdersKey = 'hidden_order_ids';

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // جلب الطلبات من الـ API
  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // تحميل قائمة الطلبات المخفية من التخزين المحلي
      await _loadHiddenIds();

      _orders = await _repository.getOrders();
      // تصفية الطلبات المخفية
      _orders.removeWhere((order) => _hiddenOrderIds.contains(order.id));
      // ترتيب تنازلي حسب التاريخ (الأحدث أولاً)
      _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // تعبئة صور المنتجات + طريقة الدفع من الكاش المحلي
      for (int i = 0; i < _orders.length; i++) {
        await _orders[i].fillCachedImages();
        // استرجاع طريقة الدفع المحفوظة محلياً (السيرفر يرجع cash دائماً)
        final cachedMethod = await PaymentMethodCache.get(
          _orders[i].orderNumber,
        );
        if (cachedMethod != null) {
          _orders[i] = _orders[i].copyWith(paymentMethod: cachedMethod);
        }
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print("Error fetching orders: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_hiddenOrdersKey) ?? [];
    _hiddenOrderIds = list.map((e) => int.tryParse(e) ?? 0).toSet();
  }

  Future<void> _saveHiddenIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _hiddenOrdersKey,
      _hiddenOrderIds.map((e) => e.toString()).toList(),
    );
  }

  // إنشاء طلب جديد (Checkout)
  Future<OrderModel?> checkout(Map<String, dynamic> orderData) async {
    _isLoading = true; // يمكن استخدام loading خاص للدفع
    notifyListeners();
    try {
      final newOrder = await _repository.createOrder(orderData);

      // إضافة الطلب الجديد للقائمة فوراً (Optimistic UI)
      // أو إعادة الجلب لضمان البيانات
      _orders.insert(0, newOrder);

      return newOrder;
    } catch (e) {
      if (kDebugMode) {
        print("Checkout Error: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة لإلغاء الطلب
  Future<void> cancelOrder(String orderNumber) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.cancelOrder(orderNumber);

      // تحديث القائمة بعد الإلغاء
      // يمكن إعادة الجلب أو تعديل الحالة محلياً
      final index = _orders.indexWhere((o) => o.orderNumber == orderNumber);
      if (index != -1) {
        // إذا أردنا إزالته أو تغيير حالته
        // في الـ Backend الحالة تصبح cancelled، لذا سنعيد تحميل القائمة لنكون دقيقين
        await fetchOrders();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error cancelling order: $e");
      }
      rethrow;
    } finally {
      // نتأكد من إيقاف التحميل فقط إذا لم تكن featchOrders قد قامت بذلك بالفعل
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearOrdersList() {
    _orders.clear();
    notifyListeners();
  }

  // إخفاء طلب من القائمة محلياً (بدون حذف من السيرفر) مع حفظ دائم
  Future<void> hideOrder(int orderId) async {
    _hiddenOrderIds.add(orderId);
    _orders.removeWhere((order) => order.id == orderId);
    await _saveHiddenIds();
    notifyListeners();
  }
}
