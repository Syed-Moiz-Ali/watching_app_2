import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:watching_app_2/core/constants/color_constants.dart';
import 'package:watching_app_2/models/video_source.dart';
import 'package:watching_app_2/services/scrapers/scraper_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:watching_app_2/core/global/app_global.dart';
import '../../models/content_item.dart';

class WebviewControllerProvider with ChangeNotifier {
  WebViewController webViewController = WebViewController();

  List<VideoSource> videos = [];
  String? firstVideoUrl;
  bool isLoading = true;
  String? error;

  // WebviewControllerProvider(this.item);

  Future<void> loadVideos(ContentItem item) async {
    try {
      isLoading = true;
      error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final newVideos = await ScraperService(item.source).getVideo(
        SMA.formatImage(baseUrl: item.source.url, image: item.contentUrl),
      );

      videos = newVideos;
      isLoading = false;

      if (videos.isNotEmpty) {
        final watchingLinks = videos.first.watchingLink;
        final Map<String, dynamic> watchingLinksMap = jsonDecode(watchingLinks);
        firstVideoUrl = watchingLinksMap.values.first;
      }

      if (firstVideoUrl != null) {
        _initializeWebView(firstVideoUrl!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      error = 'Failed to load videos: $e';
      isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _initializeWebView(String videoUrl) {
    webViewController = WebViewController()
      ..setBackgroundColor(AppColors.backgroundColorLight)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'VideoHandler',
        onMessageReceived: (JavaScriptMessage message) {
          log("message: ${message.message}");
          if (message.message == 'video') {
            // Pause all video elements
            webViewController.runJavaScript(
                'document.querySelectorAll("video").forEach(video => video.pause());');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            // Inject JavaScript to pause all video elements after the page is fully loaded
            webViewController.runJavaScript(
                'document.querySelectorAll("video").forEach(video => video.pause());');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(videoUrl));
  }
}
