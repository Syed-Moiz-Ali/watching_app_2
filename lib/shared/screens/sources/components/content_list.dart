import 'package:flutter/material.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';

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
    final sortedSources = List<ContentSource>.from(sources)
      ..sort((a, b) => a.name.compareTo(b.name));
    return CustomPadding(
      horizontalFactor: .02,
      // bottomFactor: .1,
      child: ListView.builder(
        itemCount: sortedSources.length,
        itemBuilder: (context, index) {
          final source = sortedSources[index];
          return SourceCard(source: source);
        },
      ),
    );
  }
}
