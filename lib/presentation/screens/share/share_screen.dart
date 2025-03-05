import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deep Link Share Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        '/details': (context) => DetailsScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    // Initialize deep link handling
    initUniLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  // Handle incoming links - both when the app is opened via a link
  // and when a link is received while the app is running
  Future<void> initUniLinks() async {
    // Handle case where app is started by a link
    try {
      final initialLink = await getInitialLink();
      if (initialLink != null) {
        _handleLink(initialLink);
      }
    } catch (e) {
      // Handle exception
      print('Error getting initial link: $e');
    }

    // Handle links received when app is already running
    _linkSubscription = linkStream.listen((String? link) {
      if (link != null) {
        _handleLink(link);
      }
    }, onError: (err) {
      // Handle exception
      print('Error in link stream: $err');
    });
  }

  void _handleLink(String link) {
    // Parse the link and navigate accordingly
    final uri = Uri.parse(link);

    // Example: yourapp://details?id=123
    if (uri.path == 'details' && uri.queryParameters.containsKey('id')) {
      final id = uri.queryParameters['id'];

      // Navigate to details screen with the id
      Navigator.of(context).pushNamed('/details', arguments: id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deep Link Share Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _shareLink,
              child: Text('Share Content'),
            ),
          ],
        ),
      ),
    );
  }

  void _shareLink() async {
    // Create a deep link for sharing
    final String contentId = '123'; // Your content id
    final String appDeepLink = 'yourapp://details?id=$contentId';
    final String webFallbackUrl =
        'https://yourwebsite.com/details?id=$contentId';

    // Share text that includes both links
    await Share.share(
      'Check out this content: $appDeepLink\n\nOr visit our website: $webFallbackUrl',
      subject: 'Amazing Content',
    );
  }
}

class DetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? contentId =
        ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Center(
        child: Text('Content Details: ${contentId ?? "Unknown"}'),
      ),
    );
  }
}
