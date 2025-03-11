// import 'package:html/dom.dart';

// class ScraperConfig {
//   // Core fields (required for all modules)
//   final ElementSelector titleSelector; // Title of the content
//   final ElementSelector thumbnailSelector; // Thumbnail image
//   final ElementSelector contentUrlSelector; // URL to the content

//   // Main selectors for querying multiple elements
//   final ElementSelector? contentSelector; // For manga pages or textual content
//   final ElementSelector? videoSelector; // For video elements (querySelectorAll)
//   final ElementSelector? detailSelector; // For manga details (querySelectorAll)

//   // Common optional fields
//   final ElementSelector?
//       previewSelector; // For TikTok previews or video thumbnails
//   final ElementSelector?
//       qualitySelector; // For resolution or quality (wallpapers, videos)
//   final ElementSelector? timeSelector; // For upload time
//   final ElementSelector? viewsSelector; // For view count
//   final ElementSelector? durationSelector; // For video/TikTok duration
//   final ElementSelector? watchingLinkSelector; // For video watch links
//   final ElementSelector? keywordsSelector; // For tags or keywords
//   final ElementSelector? similarContentSelector; // For related content

//   // Manga-specific fields
//   final ElementSelector? genreSelector; // Manga genre (e.g., action, romance)
//   final ElementSelector?
//       statusSelector; // Manga status (e.g., ongoing, completed)
//   final ElementSelector? chapterCountSelector; // Number of chapters in manga
//   final ElementSelector? chapterIdSelector; // Id of chapters in manga
//   final ElementSelector? discriptionSelector; // discription in manga
//   final ElementSelector? chapterImageSelector; // discription in manga
//   final ElementSelector? chapterDataSelector; // discription in manga

//   // TikTok-specific fields
//   final ElementSelector? userSelector; // Content creator/username
//   final ElementSelector? likesSelector; // Like count
//   final ElementSelector? commentsSelector; // Comment count

//   ScraperConfig({
//     required this.titleSelector,
//     required this.thumbnailSelector,
//     required this.contentUrlSelector,
//     this.contentSelector,
//     this.videoSelector,
//     this.detailSelector,
//     this.previewSelector,
//     this.qualitySelector,
//     this.timeSelector,
//     this.viewsSelector,
//     this.durationSelector,
//     this.watchingLinkSelector,
//     this.keywordsSelector,
//     this.similarContentSelector,
//     this.genreSelector,
//     this.statusSelector,
//     this.chapterCountSelector,
//     this.chapterIdSelector,
//     this.chapterDataSelector,
//     this.chapterImageSelector,
//     this.discriptionSelector,
//     this.userSelector,
//     this.likesSelector,
//     this.commentsSelector,
//   });
// }

// class ElementSelector {
//   final String? selector;
//   final String? attribute;
//   final Future<String> Function(Element)? customExtraction;

//   ElementSelector({
//     this.selector,
//     this.attribute,
//     this.customExtraction,
//   });
// }

import 'package:html/dom.dart';

class ElementSelector {
  final String? selector;
  final String? attribute;
  final bool? customExtraction; // Changed to bool to match JSON

  ElementSelector({
    this.selector,
    this.attribute,
    this.customExtraction,
  });

  factory ElementSelector.fromJson(Map<String, dynamic> json) {
    return ElementSelector(
      selector: json['selector'],
      attribute: json['attribute'],
      customExtraction: json['custom_extraction'],
    );
  }
}

class ScraperConfig {
  final ElementSelector titleSelector;
  final ElementSelector thumbnailSelector;
  final ElementSelector contentUrlSelector;

  final ElementSelector? contentSelector;
  final ElementSelector? videoSelector;
  final ElementSelector? detailSelector;
  final ElementSelector? previewSelector;
  final ElementSelector? qualitySelector;
  final ElementSelector? timeSelector;
  final ElementSelector? viewsSelector;
  final ElementSelector? durationSelector;
  final ElementSelector? watchingLinkSelector;
  final ElementSelector? keywordsSelector;
  final ElementSelector? similarContentSelector;
  final ElementSelector? genreSelector;
  final ElementSelector? statusSelector;
  final ElementSelector? chapterCountSelector;
  final ElementSelector? chapterIdSelector;
  final ElementSelector? chapterDataSelector;
  final ElementSelector? chapterImageSelector;
  final ElementSelector? discriptionSelector;
  final ElementSelector? userSelector;
  final ElementSelector? likesSelector;
  final ElementSelector? commentsSelector;

  ScraperConfig({
    required this.titleSelector,
    required this.thumbnailSelector,
    required this.contentUrlSelector,
    this.contentSelector,
    this.videoSelector,
    this.detailSelector,
    this.previewSelector,
    this.qualitySelector,
    this.timeSelector,
    this.viewsSelector,
    this.durationSelector,
    this.watchingLinkSelector,
    this.keywordsSelector,
    this.similarContentSelector,
    this.genreSelector,
    this.statusSelector,
    this.chapterCountSelector,
    this.chapterIdSelector,
    this.chapterDataSelector,
    this.chapterImageSelector,
    this.discriptionSelector,
    this.userSelector,
    this.likesSelector,
    this.commentsSelector,
  });

  factory ScraperConfig.fromJson(Map<String, dynamic> json) {
    return ScraperConfig(
      titleSelector: ElementSelector.fromJson(json['title_selector'] ?? {}),
      thumbnailSelector:
          ElementSelector.fromJson(json['thumbnail_selector'] ?? {}),
      contentUrlSelector:
          ElementSelector.fromJson(json['content_url_selector'] ?? {}),
      contentSelector: json['content_selector'] != null
          ? ElementSelector.fromJson(json['content_selector'])
          : null,
      videoSelector: json['video_selector'] != null
          ? ElementSelector.fromJson(json['video_selector'])
          : null,
      detailSelector: json['detail_selector'] != null
          ? ElementSelector.fromJson(json['detail_selector'])
          : null,
      previewSelector: json['preview_selector'] != null
          ? ElementSelector.fromJson(json['preview_selector'])
          : null,
      qualitySelector: json['quality_selector'] != null
          ? ElementSelector.fromJson(json['quality_selector'])
          : null,
      timeSelector: json['time_selector'] != null
          ? ElementSelector.fromJson(json['time_selector'])
          : null,
      viewsSelector: json['views_selector'] != null
          ? ElementSelector.fromJson(json['views_selector'])
          : null,
      durationSelector: json['duration_selector'] != null
          ? ElementSelector.fromJson(json['duration_selector'])
          : null,
      watchingLinkSelector: json['watching_link_selector'] != null
          ? ElementSelector.fromJson(json['watching_link_selector'])
          : null,
      keywordsSelector: json['keywords_selector'] != null
          ? ElementSelector.fromJson(json['keywords_selector'])
          : null,
      similarContentSelector: json['similar_content_selector'] != null
          ? ElementSelector.fromJson(json['similar_content_selector'])
          : null,
      genreSelector: json['genre_selector'] != null
          ? ElementSelector.fromJson(json['genre_selector'])
          : null,
      statusSelector: json['status_selector'] != null
          ? ElementSelector.fromJson(json['status_selector'])
          : null,
      chapterCountSelector: json['chapter_count_selector'] != null
          ? ElementSelector.fromJson(json['chapter_count_selector'])
          : null,
      chapterIdSelector: json['chapter_id_selector'] != null
          ? ElementSelector.fromJson(json['chapter_id_selector'])
          : null,
      chapterDataSelector: json['chapter_data_selector'] != null
          ? ElementSelector.fromJson(json['chapter_data_selector'])
          : null,
      chapterImageSelector: json['chapter_image_selector'] != null
          ? ElementSelector.fromJson(json['chapter_image_selector'])
          : null,
      discriptionSelector: json['discription_selector'] != null
          ? ElementSelector.fromJson(json['discription_selector'])
          : null,
      userSelector: json['user_selector'] != null
          ? ElementSelector.fromJson(json['user_selector'])
          : null,
      likesSelector: json['likes_selector'] != null
          ? ElementSelector.fromJson(json['likes_selector'])
          : null,
      commentsSelector: json['comments_selector'] != null
          ? ElementSelector.fromJson(json['comments_selector'])
          : null,
    );
  }
}
