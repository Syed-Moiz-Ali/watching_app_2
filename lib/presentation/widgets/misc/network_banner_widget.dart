import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/presentation/widgets/buttons/primary_button.dart';
import 'package:watching_app_2/presentation/widgets/misc/custom_gap.dart';
import 'package:watching_app_2/presentation/widgets/misc/text_widget.dart';
import '../../../core/services/network_service.dart';

class NetworkBannerWidget extends StatefulWidget {
  const NetworkBannerWidget({super.key});

  @override
  State<NetworkBannerWidget> createState() => _NetworkBannerWidgetState();
}

class _NetworkBannerWidgetState extends State<NetworkBannerWidget> {
  bool _isDismissed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to network status changes
    final networkService =
        Provider.of<NetworkServiceProvider>(context, listen: true);
    // Reset dismiss state when connection is restored
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
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Slide in from the top when appearing, slide out when disappearing
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1), // Start above the screen
              end: Offset.zero, // End at normal position
            ).animate(animation),
            child: child,
          );
        },
        child: networkService.isConnected || _isDismissed
            ? const SizedBox.shrink(key: ValueKey("empty"))
            : MyCustomBanner(
                key: const ValueKey("banner"),
                onDismiss: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
                onRetry: () {
                  networkService.checkNetworkStatus();
                },
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
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F), // Solid red background
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Wifi-off icon
          const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 24,
          ),
          const CustomGap(widthFactor: .03),
          // Offline message
          const Expanded(
            child: TextWidget(
              text: "You are offline! Check your internet connection.",
              color: Colors.white,
              fontWeight: FontWeight.w500,
              maxLine: 4,
            ),
          ),
          const CustomGap(widthFactor: .01),
          // Retry button
          PrimaryButton(
            onTap: onRetry,

            bgColor: AppColors.backgroundColorLight,
            width: .25,
            height: .05,
            borderRadius: 100.w,
            // style: ElevatedButton.styleFrom(
            //   backgroundColor: Colors.white,
            //   foregroundColor: const Color(0xFFD32F2F),
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   elevation: 2,
            // ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  size: 18,
                  color: Color(0xFFD32F2F),
                ),
                SizedBox(width: 4),
                TextWidget(
                  text: "Retry",
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Dismiss icon
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
