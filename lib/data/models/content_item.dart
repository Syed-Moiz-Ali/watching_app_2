import 'package:watching_app_2/data/models/content_source.dart';

class ContentItem {
  final String title;
  final String duration;
  final String preview;
  final String quality;
  final String time;
  final String thumbnailUrl;
  final String contentUrl;
  final String views;
  final ContentSource source;
  final DateTime scrapedAt;

  ContentItem({
    required this.duration,
    required this.preview,
    required this.quality,
    required this.time,
    required this.title,
    required this.views,
    required this.thumbnailUrl,
    required this.contentUrl,
    required this.source,
    required this.scrapedAt,
  });
}
