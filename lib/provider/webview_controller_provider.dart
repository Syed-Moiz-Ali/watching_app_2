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
  bool isWebViewInitialized = false;

  List<VideoSource> videos = [];
  String? firstVideoUrl;
  bool isLoading = true;
  String? error;

  Future<void> loadVideos(ContentItem item) async {
    log("WebViewProvider: Starting to load videos for ${item.contentUrl}");
    ScraperService scraperService = ScraperService(item.source);
    try {
      isLoading = true;
      error = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });

      log("WebViewProvider: Fetching videos using scraper service");
      final newVideos = await scraperService.getVideo(
        SMA.formatImage(baseUrl: item.source.url, image: item.contentUrl),
      );

      videos = newVideos;
      isLoading = false;
      log("WebViewProvider: Found ${videos.length} videos");

      if (videos.isNotEmpty) {
        final watchingLinks = videos.first.watchingLink;
        final Map<String, dynamic> watchingLinksMap = jsonDecode(watchingLinks);
        firstVideoUrl = watchingLinksMap.values.first;
        log("WebViewProvider: First video URL: $firstVideoUrl");
      } else {
        log("WebViewProvider: No videos found");
      }

      if (firstVideoUrl != null) {
        log("WebViewProvider: Initializing WebView with URL");
        _initializeWebView(firstVideoUrl!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      error = 'Failed to load videos: $e';
      isLoading = false;
      log("WebViewProvider ERROR: $error", error: e);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _initializeWebView(String videoUrl) {
    log("WebViewProvider: Initializing WebView. Currently initialized: $isWebViewInitialized");

    if (isWebViewInitialized) {
      log("WebViewProvider: WebView already initialized. Disposing first...");
      disposeWebView();
      webViewController = WebViewController();
    }

    log("WebViewProvider: Setting up new WebViewController for URL: $videoUrl");
    webViewController = WebViewController()
      ..setBackgroundColor(AppColors.backgroundColorLight)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..addJavaScriptChannel(
        'VideoHandler',
        onMessageReceived: (JavaScriptMessage message) {
          log("WebViewProvider: Received message from JS channel: ${message.message}");
          if (message.message == 'fullscreenEnter') {
            log("WebViewProvider: Entering fullscreen mode");
            _setLandscapeOrientation();
          } else if (message.message == 'fullscreenExit') {
            log("WebViewProvider: Exiting fullscreen mode");
            _setPortraitOrientation();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log("WebViewProvider: Page load started: $url");
            isLoading = true;
          },
          onPageFinished: (String url) {
            log("WebViewProvider: Page load finished: $url");
            isLoading = false;

            log("WebViewProvider: Injecting JavaScript handlers");
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
            
            console.log("WebView JS: Event listeners initialized");
          ''').then((_) {
              log("WebViewProvider: JavaScript injection successful");
            }).catchError((e) {
              log("WebViewProvider ERROR: Failed to inject JavaScript: $e",
                  error: e);
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            log("WebViewProvider: Navigation request to: ${request.url}");
            if (request.url.startsWith('https://www.youtube.com/')) {
              log("WebViewProvider: Blocking YouTube navigation");
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            log("WebViewProvider ERROR: WebView resource error: ${error.description}",
                error: error);
          },
        ),
      );

    log("WebViewProvider: Loading URL in WebView: $videoUrl");
    webViewController.loadRequest(Uri.parse(videoUrl)).then((_) {
      log("WebViewProvider: URL load request sent successfully");
    }).catchError((e) {
      log("WebViewProvider ERROR: Failed to load URL: $e", error: e);
    });

    isWebViewInitialized = true;
    log("WebViewProvider: WebView initialization complete. isWebViewInitialized = $isWebViewInitialized");
    notifyListeners();
  }

  void _setLandscapeOrientation() {
    log("WebViewProvider: Setting landscape orientation");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Animate to fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    log("WebViewProvider: Landscape orientation and immersive mode set");
  }

  void _setPortraitOrientation() {
    log("WebViewProvider: Setting portrait orientation");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Animate back from fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    log("WebViewProvider: Portrait orientation and edge-to-edge mode set");
  }

  void disposeWebView() {
    log("WebViewProvider: Disposing WebView. Current state - initialized: $isWebViewInitialized");
    if (!isWebViewInitialized) {
      log("WebViewProvider: WebView not initialized, nothing to dispose");
      return;
    }

    log("WebViewProvider: Resetting orientation to portrait");
    _setPortraitOrientation();

    log("WebViewProvider: Cleaning up JavaScript event listeners");
    webViewController.runJavaScript('''
      try {
        // Remove event listeners from videos
        document.querySelectorAll("video").forEach(video => {
          video.pause();
          video.removeEventListener('play', null);
          video.removeEventListener('fullscreenchange', null);
          video.removeEventListener('webkitfullscreenchange', null);
        });
        
        // Remove event listeners from iframes
        document.querySelectorAll("iframe").forEach(iframe => {
          iframe.removeEventListener('fullscreenchange', null);
          iframe.removeEventListener('webkitfullscreenchange', null);
        });
        
        console.log("WebView JS: Event listeners removed");
        return true;
      } catch(e) {
        console.error("WebView JS ERROR: " + e.toString());
        return false;
      }
    ''').then((_) {
      log("WebViewProvider: JavaScript cleanup completed");
    }).catchError((error) {
      log("WebViewProvider ERROR: Error cleaning up JavaScript: $error",
          error: error);
    });

    isWebViewInitialized = false;
    log("WebViewProvider: WebView disposal complete. isWebViewInitialized = $isWebViewInitialized");
    notifyListeners();
  }

  @override
  void dispose() {
    log("WebViewProvider: Full provider disposal triggered");
    if (isWebViewInitialized) {
      log("WebViewProvider: WebView is initialized, disposing WebView first");
      disposeWebView();
    }

    log("WebViewProvider: Clearing videos and URL references");
    videos.clear();
    firstVideoUrl = null;

    log("WebViewProvider: Calling super.dispose()");
    super.dispose();
    log("WebViewProvider: Provider fully disposed");
  }
}
