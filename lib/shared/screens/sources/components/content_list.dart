import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watching_app_2/data/models/content_source.dart';
import 'package:watching_app_2/shared/widgets/misc/padding.dart';
import '../../../widgets/misc/text_widget.dart';
import 'source_card.dart';

class ContentList extends StatelessWidget {
  final List<ContentSource> sources;

  const ContentList({
    required this.sources,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return _buildEmptyState(context);
    }

    final sortedSources = List<ContentSource>.from(sources)
      ..sort((a, b) => a.name.compareTo(b.name));

    return CustomPadding(
      horizontalFactor: .02,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: sortedSources.length,
        itemBuilder: (context, index) {
          final source = sortedSources[index];
          return SourceCard(source: source, index: index);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.source_outlined,
                size: 48,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(curve: Curves.easeOutBack),

            const SizedBox(height: 24),

            // Title
            TextWidget(
              text: 'No Sources Available',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            // Description
            TextWidget(
              text:
                  'There are no content sources available in this category at the moment.',
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              textAlign: TextAlign.center,
              maxLine: 3,
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
