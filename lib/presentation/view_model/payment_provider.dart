import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ztajir_furniture/data/models/card_model.dart';

class PaymentProvider extends ChangeNotifier {
  List<CardModel> _cards = [];
  bool _isLoading = false;

  List<CardModel> get cards => _cards;
  bool get isLoading => _isLoading;

  String _selectedMethodId = 'cash'; // Default to cash
  String get selectedMethodId => _selectedMethodId;

  PaymentProvider() {
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load saved cards
      final cardsString = prefs.getString('saved_cards');
      if (cardsString != null) {
        final List<dynamic> decodedList = jsonDecode(cardsString);
        _cards = decodedList.map((item) => CardModel.fromMap(item)).toList();
      }

      // Load selected method
      _selectedMethodId = prefs.getString('selected_payment_method') ?? 'cash';
    } catch (e) {
      debugPrint('Error loading payment data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectMethod(String methodId) async {
    _selectedMethodId = methodId;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_payment_method', methodId);
    } catch (e) {
      debugPrint('Error saving selected method: $e');
    }
  }

  Future<void> addCard(CardModel card) async {
    _cards.add(card);
    await _saveCards();
    notifyListeners();
  }

  Future<void> removeCard(String id) async {
    _cards.removeWhere((item) => item.id == id);
    await _saveCards();
    notifyListeners();
  }

  Future<void> _saveCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> cardsMap = _cards
          .map((card) => card.toMap())
          .toList();
      await prefs.setString('saved_cards', jsonEncode(cardsMap));
    } catch (e) {
      debugPrint('Error saving cards: $e');
    }
  }
}
