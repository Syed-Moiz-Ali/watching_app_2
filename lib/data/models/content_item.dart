import 'package:watching_app_2/data/models/content_source.dart';

class ContentItem {
  final String title; // Required: Title of the content (all modules)
  final String duration; // Optional: Duration (videos, TikTok)
  final String preview; // Optional: Preview image or video (TikTok, videos)
  final String quality; // Optional: Quality (videos, wallpapers)
  final String time; // Optional: Upload time (all modules)
  final String thumbnailUrl; // Required: Thumbnail image URL (all modules)
  final String contentUrl; // Required: URL to the content (all modules)
  final String views; // Optional: View count (videos, TikTok)
  final ContentSource source; // Required: Source of the content (all modules)
  final DateTime scrapedAt; // Required: When the item was scraped (all modules)

  // Manga-specific fields
  final String genre; // Optional: Genre (manga)
  final String status; // Optional: Status (manga, e.g., ongoing, completed)
  final String chapterCount; // Optional: Number of chapters (manga)

  // TikTok-specific fields
  final String user; // Optional: Creator/username (TikTok)
  final String likes; // Optional: Like count (TikTok)
  final String comments; // Optional: Comment count (TikTok)

  // // Video-specific fields
  // final String? category; // Optional: Category (videos)

  // // Wallpaper-specific fields
  // final String? resolution; // Optional: Resolution (wallpapers)
  // final String? size; // Optional: File size (wallpapers)

  ContentItem({
    required this.title,
    this.duration = '0:00',
    this.preview = '',
    this.quality = "HD",
    this.time = "0:00",
    required this.thumbnailUrl,
    required this.contentUrl,
    this.views = "0",
    required this.source,
    required this.scrapedAt,
    this.genre = '',
    this.status = '',
    this.chapterCount = '',
    this.user = '',
    this.likes = '',
    this.comments = '',
    // this.category,
    // this.resolution,
    // this.size,
  });
}
