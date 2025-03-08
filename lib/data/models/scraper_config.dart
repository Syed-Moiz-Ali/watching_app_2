import 'package:html/dom.dart';

class ScraperConfig {
  // Core fields (required for all modules)
  final ElementSelector titleSelector; // Title of the content
  final ElementSelector thumbnailSelector; // Thumbnail image
  final ElementSelector contentUrlSelector; // URL to the content

  // Common optional fields
  final ElementSelector? contentSelector; // For manga pages or video content
  final ElementSelector?
      previewSelector; // For TikTok previews or video thumbnails
  final ElementSelector?
      qualitySelector; // For resolution or quality (wallpapers, videos)
  final ElementSelector? timeSelector; // For upload time
  final ElementSelector? viewsSelector; // For view count
  final ElementSelector? durationSelector; // For video/TikTok duration
  final ElementSelector? watchingLinkSelector; // For video watch links
  final ElementSelector? videoSelector; // For video source URLs
  final ElementSelector? keywordsSelector; // For tags or keywords
  final ElementSelector? similarContentSelector; // For related content

  // Manga-specific fields
  final ElementSelector? genreSelector; // Manga genre (e.g., action, romance)
  final ElementSelector?
      statusSelector; // Manga status (e.g., ongoing, completed)
  final ElementSelector? chapterCountSelector; // Number of chapters in manga

  // TikTok-specific fields
  final ElementSelector? userSelector; // Content creator/username
  final ElementSelector? likesSelector; // Like count
  final ElementSelector? commentsSelector; // Comment count

  // Video-specific fields
  // final ElementSelector? categorySelector; // Category or genre (e.g., comedy, adult)

  // Wallpaper-specific fields
  // final ElementSelector? resolutionSelector; // Resolution (e.g., 1920x1080)
  // final ElementSelector? sizeSelector; // File size (e.g., 2MB)

  ScraperConfig({
    required this.titleSelector,
    required this.thumbnailSelector,
    required this.contentUrlSelector,
    this.contentSelector,
    this.previewSelector,
    this.qualitySelector,
    this.timeSelector,
    this.viewsSelector,
    this.durationSelector,
    this.watchingLinkSelector,
    this.videoSelector,
    this.keywordsSelector,
    this.similarContentSelector,
    this.genreSelector,
    this.statusSelector,
    this.chapterCountSelector,
    this.userSelector,
    this.likesSelector,
    this.commentsSelector,
    // this.categorySelector,
    // this.resolutionSelector,
    // this.sizeSelector,
  });
}

class ElementSelector {
  final String? selector;
  final String? attribute;
  final Future<String> Function(Element)? customExtraction;

  ElementSelector({
    this.selector,
    this.attribute,
    this.customExtraction,
  });
}
