import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Connectivity Provider - للتحقق من اتصال الإنترنت
class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  bool _isConnected = true;
  bool _isChecking = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool get isConnected => _isConnected;
  bool get isChecking => _isChecking;

  ConnectivityProvider() {
    _initConnectivity();
    _startListening();
  }

  /// التحقق الأولي من الاتصال
  Future<void> _initConnectivity() async {
    _isChecking = true;
    notifyListeners();

    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      _isConnected = false;
    }

    _isChecking = false;
    notifyListeners();
  }

  /// الاستماع لتغييرات الاتصال
  void _startListening() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  /// تحديث حالة الاتصال
  void _updateConnectionStatus(List<ConnectivityResult> result) {
    final wasConnected = _isConnected;

    _isConnected =
        result.isNotEmpty && !result.contains(ConnectivityResult.none);

    if (wasConnected != _isConnected) {
      notifyListeners();
    }
  }

  /// إعادة المحاولة
  Future<void> retry() async {
    await _initConnectivity();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
