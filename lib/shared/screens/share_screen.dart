// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler extends StatefulWidget {
  const DeepLinkHandler({super.key});

  @override
  _DeepLinkHandlerState createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler>
    with WidgetsBindingObserver {
  StreamSubscription? _linkSubscription;

  // Deep link data states
  String _rawLink = 'No link received yet';
  String _path = 'No path detected';
  String _id = 'No ID found';
  Map<String, String> _queryParams = {};
  bool _hasDeepLinkData = false;
  DateTime? _lastLinkReceived;
  String _errorMessage = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize deep link handling with a slight delay to ensure
    // the app is fully loaded
    Future.delayed(const Duration(milliseconds: 200), () {
      initDeepLinks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background, check for new deep links
    if (state == AppLifecycleState.resumed) {
      _checkInitialLink();
    }
  }

  // Initialize deep link handling
  Future<void> initDeepLinks() async {
    // First handle case where app is started from a deep link
    try {
      await _checkInitialLink();

      // Listen for incoming links while app is running
      _linkSubscription = linkStream.listen(_handleIncomingLink,
          onError: _handleLinkError, cancelOnError: false);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize deep links: $e';
        _isInitialized = false;
      });
      debugPrint('Deep link initialization error: $e');
    }
  }

  // Check if app was opened with a deep link
  Future<void> _checkInitialLink() async {
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        debugPrint('App opened with initial link: $initialLink');
        _handleIncomingLink(initialLink);
      } else {
        debugPrint('No initial link found');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting initial link: $e';
      });
      debugPrint('Error getting initial link: $e');
    }
  }

  // Process incoming deep links
  void _handleIncomingLink(String? link) {
    if (link == null) return;

    debugPrint('Received deep link: $link');

    setState(() {
      _rawLink = link;
      _lastLinkReceived = DateTime.now();
      _errorMessage = '';

      try {
        final uri = Uri.parse(link);

        debugPrint('Deep link URI components:');
        debugPrint('  Scheme: ${uri.scheme}');
        debugPrint('  Host: ${uri.host}');
        debugPrint('  Path: ${uri.path}');
        debugPrint('  Query params: ${uri.queryParameters}');

        // Extract the path (remove initial slash if present)
        _path = uri.path.startsWith('/') ? uri.path.substring(1) : uri.path;

        // For empty path cases (when the URI is just scheme://host)
        if (_path.isEmpty && uri.host.isNotEmpty) {
          _path = uri.host;
        }

        // Extract the ID from query parameters
        _id = uri.queryParameters['id'] ?? 'No ID found';

        // Store all query parameters
        _queryParams = Map<String, String>.from(uri.queryParameters);

        _hasDeepLinkData = true;
      } catch (e) {
        _errorMessage = 'Failed to parse deep link: $e';
        debugPrint('Error parsing deep link: $e');
      }
    });
  }

  // Handle deep link errors
  void _handleLinkError(Object error) {
    debugPrint('Deep link error: $error');
    setState(() {
      _errorMessage = 'Deep link error: $error';
    });
  }

  // Share a test deep link
  void _shareTestLink() async {
    final String contentId =
        '${DateTime.now().millisecondsSinceEpoch}'; // Use timestamp for unique ID
    final String appDeepLink =
        'yourapp://details?id=$contentId&source=share&time=${DateTime.now().toString()}';
    final String webFallbackUrl =
        'https://yourwebsite.com/details?id=$contentId';

    try {
      await Share.share(
        'Check out this content:\n$appDeepLink\n\nOr visit our website: $webFallbackUrl',
        subject: 'Deep Link Test',
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Share error: $e';
      });
      debugPrint('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deep Link Handler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _checkInitialLink();
            },
            tooltip: 'Check for deep links',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status card
              Card(
                elevation: 4,
                color: _isInitialized ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isInitialized ? Icons.check_circle : Icons.error,
                            color: _isInitialized ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isInitialized
                                ? 'Deep Link Handler Initialized'
                                : 'Initialization Failed',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage,
                            style: TextStyle(color: Colors.red[700]),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Deep link data display
              Expanded(
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deep Link Data',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),

                          // Data section
                          if (_hasDeepLinkData) ...[
                            _buildDataRow('Last received',
                                _lastLinkReceived?.toString() ?? 'Unknown'),
                            _buildDataRow('Raw link', _rawLink),
                            _buildDataRow('Path', _path),
                            _buildDataRow('ID', _id, highlight: true),
                            const SizedBox(height: 8),
                            const Text(
                              'All Query Parameters:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ..._queryParams.entries.map((entry) =>
                                _buildDataRow(entry.key, entry.value)),
                          ] else ...[
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Text(
                                  'No deep link data received yet',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Test buttons
              ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share Test Deep Link'),
                onPressed: _shareTestLink,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                label: const Text('Clear Data'),
                onPressed: () {
                  setState(() {
                    _rawLink = 'No link received yet';
                    _path = 'No path detected';
                    _id = 'No ID found';
                    _queryParams = {};
                    _hasDeepLinkData = false;
                    _lastLinkReceived = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build data row widgets
  Widget _buildDataRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: highlight ? const EdgeInsets.all(4.0) : null,
              decoration: highlight
                  ? BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(4),
                    )
                  : null,
              child: Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
