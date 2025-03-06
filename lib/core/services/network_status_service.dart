import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkServiceProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;
  StreamSubscription? _subscription;

  bool get isConnected => _isConnected;

  void initConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool newStatus = results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);

    if (_isConnected != newStatus) {
      _isConnected = newStatus;
      notifyListeners(); // Notify UI globally
    }
  }

  // Added method to manually check network status
  Future<void> checkNetworkStatus() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
