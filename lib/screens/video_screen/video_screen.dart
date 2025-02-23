import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:watching_app_2/core/enums/app_enums.dart';
import 'package:watching_app_2/models/content_item.dart';
import 'package:watching_app_2/provider/webview_controller_provider.dart';
import 'package:watching_app_2/widgets/custom_appbar.dart';
import 'package:watching_app_2/widgets/loading_indicator.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/text_widget.dart';

class VideoScreen extends StatefulWidget {
  final ContentItem item;

  const VideoScreen({super.key, required this.item});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    var provider = context.watch<WebviewControllerProvider>();
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.item.title,
        automaticallyImplyLeading: true,
        styleType: TextStyleType.body,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: provider.isLoading
              ? _buildLoadingIndicator()
              : provider.error != null
                  ? _buildErrorMessage(provider)
                  : _buildWebView(provider),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CustomLoadingIndicator(),
    );
  }

  Widget _buildErrorMessage(WebviewControllerProvider provider) {
    return Center(
      child: AnimatedOpacity(
        opacity: provider.error == null ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        child: TextWidget(
          text: provider.error ?? 'Unknown error occurred!',
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildWebView(WebviewControllerProvider provider) {
    if (provider.firstVideoUrl == null) {
      return const Center(
          child: TextWidget(
        text: 'No video available',
        styleType: TextStyleType.subheading2,
      ));
    } else {
      return SizedBox(
        height: 35.h,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: WebViewWidget(
              controller: provider.webViewController,
            ),
          ),
        ),
      );
    }
  }
}
