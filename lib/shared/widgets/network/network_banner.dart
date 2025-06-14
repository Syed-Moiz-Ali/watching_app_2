import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../core/services/network_status_service.dart';

class NetworkBanner extends StatefulWidget {
  final bool showQualityInfo;
  final bool autoHide;
  final Duration autoHideDuration;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;

  const NetworkBanner({
    super.key,
    this.showQualityInfo = true,
    this.autoHide = true,
    this.autoHideDuration = const Duration(seconds: 5),
    this.onConnected,
    this.onDisconnected,
  });

  @override
  State<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends State<NetworkBanner>
    with TickerProviderStateMixin {
  bool _isDismissed = false;
  bool _isRetrying = false;
  bool _wasConnected = true;

  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final networkService = Provider.of<NetworkServiceProvider>(context);
    final isConnected = networkService.isConnected;

    // Handle connection state changes
    if (_wasConnected != isConnected) {
      if (isConnected && _isDismissed) {
        setState(() {
          _isDismissed = false;
        });
        widget.onConnected?.call();

        if (widget.autoHide) {
          Future.delayed(widget.autoHideDuration, () {
            if (mounted && isConnected) {
              setState(() {
                _isDismissed = true;
              });
            }
          });
        }
      } else if (!isConnected) {
        widget.onDisconnected?.call();
      }
      _wasConnected = isConnected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkServiceProvider>(
      builder: (context, networkService, child) {
        final status = networkService.networkStatus;

        return Material(
          child: _shouldShowBanner(status)
              ? NetworkStatusBanner(
                  key: ValueKey("banner-${status.isConnected}"),
                  networkStatus: status,
                  isRetrying: _isRetrying,
                  showQualityInfo: widget.showQualityInfo,
                  pulseAnimation: _pulseAnimation,
                  onDismiss: () => setState(() => _isDismissed = true),
                  onRetry: _handleRetry,
                )
              : const SizedBox.shrink(key: ValueKey("empty")),
        );
      },
    );
  }

  bool _shouldShowBanner(NetworkStatus status) {
    if (_isDismissed) return false;
    return !status.isConnected ||
        status.quality == NetworkQuality.poor ||
        status.errorMessage != null;
  }

  Future<void> _handleRetry() async {
    setState(() {
      _isRetrying = true;
    });

    final networkService =
        Provider.of<NetworkServiceProvider>(context, listen: false);
    await networkService.checkNetworkStatus();

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}

class NetworkStatusBanner extends StatelessWidget {
  final NetworkStatus networkStatus;
  final bool isRetrying;
  final bool showQualityInfo;
  final Animation<double> pulseAnimation;
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  const NetworkStatusBanner({
    super.key,
    required this.networkStatus,
    required this.isRetrying,
    required this.showQualityInfo,
    required this.pulseAnimation,
    required this.onDismiss,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: _getGradient(),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildStatusIcon(),
              const CustomGap(widthFactor: .03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: _getStatusTitle(),
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    if (_getStatusSubtitle().isNotEmpty)
                      TextWidget(
                        text: _getStatusSubtitle(),
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                  ],
                ),
              ),
              const CustomGap(widthFactor: .02),
              _buildActionButton(),
              const SizedBox(width: 8),
              _buildDismissButton(),
            ],
          ),
          if (showQualityInfo && networkStatus.isConnected) _buildQualityInfo(),
        ],
      ),
    );
  }

  LinearGradient _getGradient() {
    if (!networkStatus.isConnected) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
      );
    }

    switch (networkStatus.quality) {
      case NetworkQuality.excellent:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        );
      case NetworkQuality.good:
        return const LinearGradient(
          colors: [Color(0xFF8BC34A), Color(0xFF689F38)],
        );
      case NetworkQuality.fair:
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
        );
      case NetworkQuality.poor:
        return const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFE64A19)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
        );
    }
  }

  Widget _buildStatusIcon() {
    IconData iconData;

    if (!networkStatus.isConnected) {
      iconData = Icons.wifi_off;
    } else {
      switch (networkStatus.connectionType) {
        case ConnectionType.wifi:
          iconData = _getWifiIcon();
          break;
        case ConnectionType.mobile:
          iconData = Icons.signal_cellular_4_bar;
          break;
        case ConnectionType.ethernet:
          iconData = Icons.settings_ethernet_rounded;
          break;
        default:
          iconData = Icons.network_check;
      }
    }

    return Icon(
      iconData,
      color: Colors.white,
      size: 28,
    );
  }

  IconData _getWifiIcon() {
    switch (networkStatus.quality) {
      case NetworkQuality.excellent:
        return Icons.wifi;
      case NetworkQuality.good:
        return Icons.wifi;
      case NetworkQuality.fair:
        return Icons.wifi_2_bar;
      case NetworkQuality.poor:
        return Icons.wifi_1_bar;
      default:
        return Icons.wifi_off;
    }
  }

  String _getStatusTitle() {
    if (!networkStatus.isConnected) {
      return "No Internet Connection";
    }

    if (networkStatus.quality == NetworkQuality.poor) {
      return "Poor Connection Quality";
    }

    if (networkStatus.errorMessage != null) {
      return "Connection Issue";
    }

    return "Connected via ${_getConnectionTypeString()}";
  }

  String _getStatusSubtitle() {
    if (!networkStatus.isConnected) {
      return "Check your connection and try again";
    }

    if (networkStatus.quality == NetworkQuality.poor) {
      return "Connection is slow or unstable";
    }

    if (networkStatus.errorMessage != null) {
      return networkStatus.errorMessage!;
    }

    return "${_getQualityString()} quality";
  }

  String _getConnectionTypeString() {
    switch (networkStatus.connectionType) {
      case ConnectionType.wifi:
        return "Wi-Fi";
      case ConnectionType.mobile:
        return "Mobile Data";
      case ConnectionType.ethernet:
        return "Ethernet";
      case ConnectionType.bluetooth:
        return "Bluetooth";
      case ConnectionType.vpn:
        return "VPN";
      case ConnectionType.other:
        return "Network";
      case ConnectionType.none:
        return "None";
    }
  }

  String _getQualityString() {
    switch (networkStatus.quality) {
      case NetworkQuality.excellent:
        return "Excellent";
      case NetworkQuality.good:
        return "Good";
      case NetworkQuality.fair:
        return "Fair";
      case NetworkQuality.poor:
        return "Poor";
      case NetworkQuality.disconnected:
        return "Disconnected";
    }
  }

  Widget _buildActionButton() {
    if (isRetrying) {
      return Container(
        width: 80,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    return PrimaryButton(
      onTap: onRetry,
      bgColor: Colors.white.withOpacity(0.9),
      width: .22,
      height: .045,
      borderRadius: 18,
      elevation: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.refresh,
            size: 16,
            color: _getGradient().colors.first,
          ),
          const SizedBox(width: 4),
          TextWidget(
            text: "Retry",
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: _getGradient().colors.first,
          ),
        ],
      ),
    );
  }

  Widget _buildDismissButton() {
    return IconButton(
      onPressed: onDismiss,
      icon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 20,
      ),
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(
        minWidth: 32,
        minHeight: 32,
      ),
    );
  }

  Widget _buildQualityInfo() {
    if (networkStatus.latency == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Latency: ${networkStatus.latency}ms",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(
            "Last checked: ${_formatTime(networkStatus.lastChecked)}",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else {
      return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    }
  }
}
