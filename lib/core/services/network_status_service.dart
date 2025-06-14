import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum NetworkQuality { excellent, good, fair, poor, disconnected }

enum ConnectionType { wifi, mobile, ethernet, bluetooth, vpn, other, none }

class NetworkStatus {
  final bool isConnected;
  final ConnectionType connectionType;
  final NetworkQuality quality;
  final int? latency;
  final DateTime lastChecked;
  final String? errorMessage;

  const NetworkStatus({
    required this.isConnected,
    required this.connectionType,
    required this.quality,
    this.latency,
    required this.lastChecked,
    this.errorMessage,
  });

  NetworkStatus copyWith({
    bool? isConnected,
    ConnectionType? connectionType,
    NetworkQuality? quality,
    int? latency,
    DateTime? lastChecked,
    String? errorMessage,
  }) {
    return NetworkStatus(
      isConnected: isConnected ?? this.isConnected,
      connectionType: connectionType ?? this.connectionType,
      quality: quality ?? this.quality,
      latency: latency ?? this.latency,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class NetworkServiceProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();

  NetworkStatus _networkStatus = NetworkStatus(
    isConnected: true,
    connectionType: ConnectionType.none,
    quality: NetworkQuality.disconnected,
    lastChecked: DateTime.now(),
  );

  StreamSubscription? _connectivitySubscription;
  Timer? _qualityCheckTimer;
  Timer? _reconnectTimer;

  // Configuration
  final Duration _qualityCheckInterval = const Duration(minutes: 2);
  final Duration _reconnectInterval = const Duration(seconds: 10);
  final List<String> _testUrls = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://httpbin.org/get',
  ];

  // Getters
  NetworkStatus get networkStatus => _networkStatus;
  bool get isConnected => _networkStatus.isConnected;
  ConnectionType get connectionType => _networkStatus.connectionType;
  NetworkQuality get quality => _networkStatus.quality;
  int? get latency => _networkStatus.latency;
  DateTime get lastChecked => _networkStatus.lastChecked;

  // Initialize connectivity monitoring
  Future<void> initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);

      _startConnectivityListener();
      _startQualityMonitoring();
    } catch (e) {
      _updateNetworkStatus(
        _networkStatus.copyWith(
          isConnected: false,
          errorMessage: 'Failed to initialize connectivity: $e',
          lastChecked: DateTime.now(),
        ),
      );
    }
  }

  void _startConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) async {
        await _updateConnectionStatus(results);
      },
      onError: (error) {
        _updateNetworkStatus(
          _networkStatus.copyWith(
            isConnected: false,
            errorMessage: 'Connectivity error: $error',
            lastChecked: DateTime.now(),
          ),
        );
      },
    );
  }

  void _startQualityMonitoring() {
    _qualityCheckTimer?.cancel();
    _qualityCheckTimer = Timer.periodic(_qualityCheckInterval, (_) {
      if (_networkStatus.isConnected) {
        _checkNetworkQuality();
      }
    });
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    final connectionType = _mapConnectivityResults(results);
    final isConnected = connectionType != ConnectionType.none;

    if (!isConnected) {
      _updateNetworkStatus(
        NetworkStatus(
          isConnected: false,
          connectionType: ConnectionType.none,
          quality: NetworkQuality.disconnected,
          lastChecked: DateTime.now(),
        ),
      );
      _startReconnectTimer();
      return;
    }

    _stopReconnectTimer();

    // Perform internet connectivity test
    final hasInternetAccess = await _testInternetConnectivity();
    final quality = hasInternetAccess
        ? await _measureNetworkQuality()
        : NetworkQuality.disconnected;

    _updateNetworkStatus(
      NetworkStatus(
        isConnected: hasInternetAccess,
        connectionType: connectionType,
        quality: quality,
        latency: _networkStatus.latency,
        lastChecked: DateTime.now(),
      ),
    );
  }

  ConnectionType _mapConnectivityResults(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectionType.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionType.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectionType.ethernet;
    } else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectionType.bluetooth;
    } else if (results.contains(ConnectivityResult.vpn)) {
      return ConnectionType.vpn;
    } else if (results.contains(ConnectivityResult.other)) {
      return ConnectionType.other;
    }
    return ConnectionType.none;
  }

  Future<bool> _testInternetConnectivity() async {
    for (final url in _testUrls) {
      try {
        final response = await http.get(
          Uri.parse(url),
          headers: {'User-Agent': 'NetworkCheck/1.0'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        continue; // Try next URL
      }
    }
    return false;
  }

  Future<NetworkQuality> _measureNetworkQuality() async {
    final latency = await _measureLatency();

    if (latency == null) return NetworkQuality.poor;

    if (latency < 100) return NetworkQuality.excellent;
    if (latency < 300) return NetworkQuality.good;
    if (latency < 1000) return NetworkQuality.fair;
    return NetworkQuality.poor;
  }

  Future<int?> _measureLatency() async {
    try {
      final stopwatch = Stopwatch()..start();

      final socket = await Socket.connect('8.8.8.8', 53,
          timeout: const Duration(seconds: 5));
      socket.destroy();

      stopwatch.stop();
      final latency = stopwatch.elapsedMilliseconds;

      _updateNetworkStatus(
        _networkStatus.copyWith(
          latency: latency,
          lastChecked: DateTime.now(),
        ),
      );

      return latency;
    } catch (e) {
      return null;
    }
  }

  Future<void> _checkNetworkQuality() async {
    if (!_networkStatus.isConnected) return;

    final quality = await _measureNetworkQuality();
    _updateNetworkStatus(
      _networkStatus.copyWith(
        quality: quality,
        lastChecked: DateTime.now(),
      ),
    );
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_reconnectInterval, (_) {
      checkNetworkStatus();
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateNetworkStatus(NetworkStatus newStatus) {
    final wasConnected = _networkStatus.isConnected;
    final isNowConnected = newStatus.isConnected;

    _networkStatus = newStatus;
    notifyListeners();

    // Trigger callbacks for connection state changes
    if (!wasConnected && isNowConnected) {
      _onConnected();
    } else if (wasConnected && !isNowConnected) {
      _onDisconnected();
    }
  }

  void _onConnected() {
    debugPrint('Network connected: ${_networkStatus.connectionType}');
  }

  void _onDisconnected() {
    debugPrint('Network disconnected');
  }

  // Public methods
  Future<void> checkNetworkStatus() async {
    try {
      final results = await _connectivity.checkConnectivity();
      await _updateConnectionStatus(results);
    } catch (e) {
      _updateNetworkStatus(
        _networkStatus.copyWith(
          errorMessage: 'Manual check failed: $e',
          lastChecked: DateTime.now(),
        ),
      );
    }
  }

  Future<bool> pingHost(String host,
      {int port = 80, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  String getConnectionDescription() {
    switch (_networkStatus.connectionType) {
      case ConnectionType.wifi:
        return 'Wi-Fi';
      case ConnectionType.mobile:
        return 'Mobile Data';
      case ConnectionType.ethernet:
        return 'Ethernet';
      case ConnectionType.bluetooth:
        return 'Bluetooth';
      case ConnectionType.vpn:
        return 'VPN';
      case ConnectionType.other:
        return 'Other';
      case ConnectionType.none:
        return 'No Connection';
    }
  }

  String getQualityDescription() {
    switch (_networkStatus.quality) {
      case NetworkQuality.excellent:
        return 'Excellent';
      case NetworkQuality.good:
        return 'Good';
      case NetworkQuality.fair:
        return 'Fair';
      case NetworkQuality.poor:
        return 'Poor';
      case NetworkQuality.disconnected:
        return 'Disconnected';
    }
  }

  Color getQualityColor() {
    switch (_networkStatus.quality) {
      case NetworkQuality.excellent:
        return Colors.green;
      case NetworkQuality.good:
        return Colors.lightGreen;
      case NetworkQuality.fair:
        return Colors.orange;
      case NetworkQuality.poor:
        return Colors.red;
      case NetworkQuality.disconnected:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _qualityCheckTimer?.cancel();
    _reconnectTimer?.cancel();
    super.dispose();
  }
}
