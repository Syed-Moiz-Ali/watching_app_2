import 'package:flutter/material.dart';
import 'package:watching_app_2/models/content_source.dart';

import 'source_card.dart';

class ContentList extends StatelessWidget {
  final List<ContentSource> sources;

  const ContentList({
    required this.sources,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // If the sources list is empty, display a placeholder or error message
    if (sources.isEmpty) {
      return const Center(
        child: Text(
          'No content available.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        itemCount: sources.length,
        itemBuilder: (context, index) {
          final source = sources[index];
          return SourceCard(source: source);
        },
      ),
    );
  }
}
