import 'package:dio/dio.dart';
import 'package:ztajir_furniture/core/network/api_client.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';
import 'package:ztajir_furniture/data/models/order_model.dart';
import 'package:flutter/foundation.dart';

class OrderRepository {
  final ApiClient _apiClient;

  OrderRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _apiClient.get(ApiConstants.orders);

      if (response.data['success'] == true) {
        dynamic responseData = response.data['data'];
        List<dynamic> listData = [];

        if (responseData is List) {
          listData = responseData;
        } else if (responseData is Map<String, dynamic>) {
          // التعامل مع الـ Pagination
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            listData = responseData['data'];
          } else if (responseData.containsKey('orders') &&
              responseData['orders'] is List) {
            listData = responseData['orders'];
          }
        }

        return listData.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch orders');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching orders: $e");
      }
      rethrow;
    }
  }

  Future<OrderModel> createOrder(Map<String, dynamic> data) async {
    try {
      // إرسال JSON مباشرة (FormData لا يتعامل مع nested arrays بشكل صحيح)
      final response = await _apiClient.post(
        ApiConstants.checkout,
        data: data,
        options: Options(contentType: 'application/json'),
      );

      if (response.data['success'] == true) {
        // التحقق مما إذا كانت البيانات order object مباشرة أم داخل data
        if (response.data['data'] != null) {
          return OrderModel.fromJson(response.data['data']);
        } else if (response.data['order'] != null) {
          return OrderModel.fromJson(response.data['order']);
        }
        // Fallback
        return OrderModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create order');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error creating order: $e");
      }
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderNumber) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.orders}/$orderNumber/cancel',
        data: {},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error cancelling order: $e");
      }
      rethrow;
    }
  }
}
