import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watching_app_2/core/constants/colors.dart';
import 'package:watching_app_2/data/models/content_item.dart';
import 'package:watching_app_2/data/models/video_source.dart';
import 'package:watching_app_2/data/scrapers/scraper_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/global/globals.dart';

class WebviewProvider with ChangeNotifier {
  late WebViewController _webViewController;
  bool _isWebViewInitialized = false;
  List<VideoSource> _videos = [];
  String? _firstVideoUrl;
  bool _isLoading = true;
  String? _error;

  // Public getters
  WebViewController get webViewController => _webViewController;
  List<VideoSource> get videos => _videos;
  String? get firstVideoUrl => _firstVideoUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WebviewProvider() {
    _webViewController = WebViewController();
  }

  /// Loads video content for the given [item] and initializes the WebView.
  Future<void> loadVideos(ContentItem item) async {
    _log('Starting to load videos for ${item.contentUrl}');
    disposeWebView(); // Reset state before loading new content

    final scraperService = ScraperService(item.source);
    _setLoadingState(true);

    try {
      final formattedUrl = _formatContentUrl(item.source.url, item.contentUrl);
      _videos = await scraperService.getVideo(formattedUrl);
      _log('Found ${_videos.length} videos');

      if (_videos.isNotEmpty) {
        _firstVideoUrl = _extractFirstVideoUrl(_videos.first.watchingLink);
        _log('First video URL: $_firstVideoUrl');
        if (_firstVideoUrl != null) {
          await _initializeWebView(_firstVideoUrl!);
        }
      } else {
        _log('No videos found');
      }
      _setLoadingState(false);
    } catch (e) {
      _handleError('Failed to load videos: $e', e);
    }
  }

  /// Initializes the WebView with the provided [videoUrl].
  Future<void> _initializeWebView(String videoUrl) async {
    _log('Initializing WebView with URL: $videoUrl');
    if (_isWebViewInitialized) {
      _log('WebView already initialized. Reinitializing...');
      disposeWebView();
      _webViewController = WebViewController();
    }

    _configureWebViewController(videoUrl);
    await _webViewController.loadRequest(Uri.parse(videoUrl)).catchError((e) {
      _log('Failed to load URL: $e', error: e);
    });

    _isWebViewInitialized = true;
    _log('WebView initialization complete');
    notifyListeners();
  }

  /// Configures the WebViewController with settings and JavaScript handlers.
  void _configureWebViewController(String videoUrl) {
    _webViewController
      ..setBackgroundColor(AppColors.backgroundColorLight)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..enableZoom(false)
      ..addJavaScriptChannel('VideoHandler',
          onMessageReceived: _handleJsMessage)
      ..setNavigationDelegate(_buildNavigationDelegate());

    _log('WebViewController configured for: $videoUrl');
  }

  /// Builds the NavigationDelegate for WebView navigation handling.
  NavigationDelegate _buildNavigationDelegate() {
    return NavigationDelegate(
      onPageStarted: (url) {
        _log('Page load started: $url');
        _setLoadingState(true);
      },
      onPageFinished: (url) {
        _log('Page load finished: $url');
        _setLoadingState(false);
        _injectJavaScript();
      },
      onNavigationRequest: (request) {
        _log('Navigation request to: ${request.url}');
        if (request.url.startsWith('https://www.youtube.com/')) {
          _log('Blocking YouTube navigation');
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onWebResourceError: (error) {
        _log('WebView resource error: ${error.description}', error: error);
      },
    );
  }

  /// Handles messages from the JavaScript channel.
  void _handleJsMessage(JavaScriptMessage message) {
    _log('Received JS message: ${message.message}');
    switch (message.message) {
      case 'fullscreenEnter':
        _setLandscapeOrientation();
        break;
      case 'fullscreenExit':
        _setPortraitOrientation();
        break;
      case 'video':
        _log('Video playback started');
        break;
    }
  }

  /// Injects JavaScript to handle video events and fullscreen changes.
  void _injectJavaScript() {
    const jsCode = '''
      document.querySelectorAll("video").forEach(video => {
        video.pause();
        video.addEventListener('play', () => VideoHandler.postMessage('video'));
        video.addEventListener('fullscreenchange', () => {
          document.fullscreenElement ? VideoHandler.postMessage('fullscreenEnter') : VideoHandler.postMessage('fullscreenExit');
        });
        video.addEventListener('webkitfullscreenchange', () => {
          document.webkitFullscreenElement ? VideoHandler.postMessage('fullscreenEnter') : VideoHandler.postMessage('fullscreenExit');
        });
      });
      document.querySelectorAll("iframe").forEach(iframe => {
        iframe.addEventListener('fullscreenchange', () => {
          document.fullscreenElement ? VideoHandler.postMessage('fullscreenEnter') : VideoHandler.postMessage('fullscreenExit');
        });
        iframe.addEventListener('webkitfullscreenchange', () => {
          document.webkitFullscreenElement ? VideoHandler.postMessage('fullscreenEnter') : VideoHandler.postMessage('fullscreenExit');
        });
      });
      console.log("WebView JS: Event listeners initialized");
    ''';
    _webViewController.runJavaScript(jsCode).then((_) {
      _log('JavaScript injection successful');
    }).catchError((e) {
      _log('Failed to inject JavaScript: $e', error: e);
    });
  }

  /// Sets the device to landscape orientation with immersive mode.
  void _setLandscapeOrientation() {
    _log('Setting landscape orientation');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Resets the device to portrait orientation with edge-to-edge mode.
  void _setPortraitOrientation() {
    _log('Setting portrait orientation');
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Disposes of the WebView and cleans up resources.
  void disposeWebView() {
    if (!_isWebViewInitialized) {
      _log('WebView not initialized, nothing to dispose');
      return;
    }

    _log('Disposing WebView');
    _setPortraitOrientation();
    _cleanupJavaScript();
    _isWebViewInitialized = false;
    notifyListeners();
  }

  /// Cleans up JavaScript event listeners in the WebView.
  void _cleanupJavaScript() {
    const cleanupJs = '''
      try {
        document.querySelectorAll("video").forEach(video => {
          video.pause();
          video.removeEventListener('play', null);
          video.removeEventListener('fullscreenchange', null);
          video.removeEventListener('webkitfullscreenchange', null);
        });
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
    ''';
    _webViewController.runJavaScript(cleanupJs).then((_) {
      _log('JavaScript cleanup completed');
    }).catchError((e) {
      _log('Error cleaning up JavaScript: $e', error: e);
    });
  }

  /// Formats the content URL using the base URL and content URL.
  String _formatContentUrl(String baseUrl, String contentUrl) {
    return SMA.formatImage(
        baseUrl: baseUrl,
        image: contentUrl); // Assuming SMA is a global utility
  }

  /// Extracts the first video URL from the watching link JSON.
  String? _extractFirstVideoUrl(String watchingLink) {
    final watchingLinksMap = jsonDecode(watchingLink) as Map<String, dynamic>;
    return watchingLinksMap.values.first as String?;
  }

  /// Updates the loading state and notifies listeners.
  void _setLoadingState(bool value) {
    _isLoading = value;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// Handles errors by setting the error state and logging.
  void _handleError(String message, dynamic e) {
    _error = message;
    _isLoading = false;
    _log('ERROR: $message', error: e);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  /// Logs messages with optional error details.
  void _log(String message, {dynamic error}) {
    if (error != null) {
      log('WebviewProvider - $message', error: error);
    } else {
      log('WebviewProvider - $message');
    }
  }

  @override
  void dispose() {
    _log('Full provider disposal triggered');
    disposeWebView();
    _videos.clear();
    _firstVideoUrl = null;
    super.dispose();
    _log('Provider fully disposed');
  }
}
