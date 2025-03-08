import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/shared/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/shared/widgets/misc/gap.dart';
import 'package:watching_app_2/shared/widgets/misc/text_widget.dart';
import '../../../core/services/network_status_service.dart';

class NetworkBanner extends StatefulWidget {
  const NetworkBanner({super.key});

  @override
  State<NetworkBanner> createState() => _NetworkBannerState();
}

class _NetworkBannerState extends State<NetworkBanner> {
  bool _isDismissed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final networkService =
        Provider.of<NetworkServiceProvider>(context, listen: true);
    if (networkService.isConnected && _isDismissed) {
      setState(() {
        _isDismissed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkService = Provider.of<NetworkServiceProvider>(context);

    return Material(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            ),
          );
        },
        child: networkService.isConnected || _isDismissed
            ? const SizedBox.shrink(key: ValueKey("empty"))
            : MyCustomBanner(
                key: const ValueKey("banner"),
                onDismiss: () => setState(() => _isDismissed = true),
                onRetry: () => networkService.checkNetworkStatus(),
              ),
      ),
    );
  }
}

class MyCustomBanner extends StatelessWidget {
  final VoidCallback onDismiss;
  final VoidCallback onRetry;

  const MyCustomBanner({
    super.key,
    required this.onDismiss,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 28,
          ),
          const CustomGap(widthFactor: .04),
          const Expanded(
            child: TextWidget(
              text: "No internet. Check your connection.",
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
              maxLine: 2,
            ),
          ),
          const CustomGap(widthFactor: .02),
          PrimaryButton(
            onTap: onRetry,
            bgColor: AppColors.backgroundColorLight,
            width: .25,
            height: .05,
            borderRadius: 20,
            elevation: 2,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  size: 18,
                  color: Color(0xFFD32F2F),
                ),
                SizedBox(width: 6),
                TextWidget(
                  text: "Retry",
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
