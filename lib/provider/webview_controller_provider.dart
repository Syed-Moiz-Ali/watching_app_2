import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    ScraperService scraperService = ScraperService(item.source);
    try {
      isLoading = true;
      error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      final newVideos = await scraperService.getVideo(
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
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'VideoHandler',
        onMessageReceived: (JavaScriptMessage message) {
          log("message: ${message.message}");
          // if (message.message == 'video') {
          //   // Pause all video elements
          //   webViewController.runJavaScript(
          //       'document.querySelectorAll("video").forEach(video => video.pause());');
          // }
          // else if (message.message == 'fullscreenEnter') {
          //   _setLandscapeOrientation();
          // } else if (message.message == 'fullscreenExit') {
          //   _setPortraitOrientation();
          // }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Show loading animation

            isLoading = true;
          },
          onPageFinished: (String url) {
            // Hide loading animation

            isLoading = false;

            // Inject JavaScript to handle video elements and fullscreen events
            webViewController.runJavaScript('''
            // Pause all videos initially
            document.querySelectorAll("video").forEach(video => {
              video.pause();
              
              // Add click event listeners for play/pause
              video.addEventListener('play', function() {
                VideoHandler.postMessage('video');
              });
              
              // Track fullscreen changes for videos
              video.addEventListener('fullscreenchange', function() {
                if (document.fullscreenElement) {
                  VideoHandler.postMessage('fullscreenEnter');
                } else {
                  VideoHandler.postMessage('fullscreenExit');
                }
              });
              
              // For webkit browsers (iOS)
              video.addEventListener('webkitfullscreenchange', function() {
                if (document.webkitFullscreenElement) {
                  VideoHandler.postMessage('fullscreenEnter');
                } else {
                  VideoHandler.postMessage('fullscreenExit');
                }
              });
            });
            
            // Handle iframes (like YouTube) fullscreen events
            document.querySelectorAll("iframe").forEach(iframe => {
              iframe.addEventListener('fullscreenchange', function() {
                if (document.fullscreenElement) {
                  VideoHandler.postMessage('fullscreenEnter');
                } else {
                  VideoHandler.postMessage('fullscreenExit');
                }
              });
              
              // For webkit browsers
              iframe.addEventListener('webkitfullscreenchange', function() {
                if (document.webkitFullscreenElement) {
                  VideoHandler.postMessage('fullscreenEnter');
                } else {
                  VideoHandler.postMessage('fullscreenExit');
                }
              });
            });
            
            // Add fullscreen API interception
            const originalRequestFullscreen = Element.prototype.requestFullscreen;
            Element.prototype.requestFullscreen = function() {
              VideoHandler.postMessage('fullscreenEnter');
              return originalRequestFullscreen.apply(this, arguments);
            };
            
            document.addEventListener('fullscreenchange', function() {
              if (!document.fullscreenElement) {
                VideoHandler.postMessage('fullscreenExit');
              }
            });
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            log("WebView error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(videoUrl));
  }

// Helper method to set landscape orientation
  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Animate to fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

// Helper method to set portrait orientation
  void _setPortraitOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Animate back from fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}
