import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ztajir_furniture/data/models/product_model.dart';
import 'package:ztajir_furniture/core/constants/api_constants.dart';

class ProductDetailsService {
  static const String _baseUrl = ApiConstants.products;

  Future<ProductModel> getProductDetails(String slug) async {
    final url = Uri.parse('$_baseUrl/$slug');
    debugPrint('Fetching product details from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ProductModel.fromJson(data['data']);
        } else {
          throw Exception('Failed to load product details: ${data['message']}');
        }
      } else {
        throw Exception(
          'Failed to load product details. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching product details: $e');
      rethrow;
    }
  }

  Future<List<ProductModel>> getRelatedProducts(String categorySlug) async {
    final url = Uri.parse('$_baseUrl?category=$categorySlug&per_page=12');
    debugPrint('Fetching related products from: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true && data['data']['data'] != null) {
          final List<dynamic> productsJson = data['data']['data'];
          // Filter out null or invalid items if necessary
          return ProductModel.fromJsonList(productsJson);
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load related products. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Error fetching related products: $e');
      return [];
    }
  }
}
