import 'content_source.dart';

class VideoSource {
  final String watchingLink;
  final String keywords;
  final ContentSource source;
  final DateTime scrapedAt;

  VideoSource({
    required this.watchingLink,
    required this.keywords,
    required this.source,
    required this.scrapedAt,
  });

  factory VideoSource.fromJson(Map<String, dynamic> json) {
    return VideoSource(
      watchingLink: json['watchingLink'],
      keywords: json['keywords'],
      source: json['source'],
      scrapedAt: json['scrapedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'watchingLink': watchingLink,
      'keywords': keywords,
      // 'source': source,
      'scrapedAt': scrapedAt,
    };
  }
}
