// Represents a selector for extracting elements from a webpage
import 'dart:developer';

class ElementSelector {
  final String? selector;
  final String? attribute;
  final bool customExtraction;

  const ElementSelector({
    this.selector,
    this.attribute,
    this.customExtraction = false,
  });

  // Factory for creating from JSON with default values
  factory ElementSelector.fromJson(Map<String, dynamic> json) {
    return ElementSelector(
      selector: json['selector'] as String?,
      attribute: json['attribute'] as String?,
      customExtraction: json['custom_extraction'] as bool? ?? false,
    );
  }

  // Convert to JSON, omitting null values
  Map<String, dynamic> toJson() => {
        if (selector != null) 'selector': selector,
        if (attribute != null) 'attribute': attribute,
        if (customExtraction) 'custom_extraction': customExtraction,
      };

  // Create an empty selector
  static const ElementSelector empty = ElementSelector();
}

// Configuration for web scraping
class ScraperConfig {
  // Required selectors
  final ElementSelector titleSelector;
  final ElementSelector thumbnailSelector;
  final ElementSelector contentUrlSelector;

  // Optional content selectors
  final ElementSelector contentSelector;
  final ElementSelector videoSelector;
  final ElementSelector previewSelector;
  final ElementSelector qualitySelector;
  final ElementSelector timeSelector;
  final ElementSelector viewsSelector;
  final ElementSelector durationSelector;
  final ElementSelector watchingLinkSelector;
  final ElementSelector keywordsSelector;
  final ElementSelector similarContentSelector;

  // Optional detail selectors
  final ElementSelector detailSelector;
  final ElementSelector genreSelector;
  final ElementSelector statusSelector;
  final ElementSelector descriptionSelector; // Fixed typo from 'discription'

  // Optional chapter selectors
  final ElementSelector chaptersSelector;
  final ElementSelector chapterIdSelector;
  final ElementSelector chapterImageSelector;
  final ElementSelector chapterNameSelector;

  // Optional chapter-by-ID selectors
  final ElementSelector chapterImagesByIdSelector;
  final ElementSelector chapterTitleByIdSelector;
  final ElementSelector chapterImagesByIdSelectionSelector;

  const ScraperConfig({
    required this.titleSelector,
    required this.thumbnailSelector,
    required this.contentUrlSelector,
    this.contentSelector = ElementSelector.empty,
    this.videoSelector = ElementSelector.empty,
    this.previewSelector = ElementSelector.empty,
    this.qualitySelector = ElementSelector.empty,
    this.timeSelector = ElementSelector.empty,
    this.viewsSelector = ElementSelector.empty,
    this.durationSelector = ElementSelector.empty,
    this.watchingLinkSelector = ElementSelector.empty,
    this.keywordsSelector = ElementSelector.empty,
    this.similarContentSelector = ElementSelector.empty,
    this.detailSelector = ElementSelector.empty,
    this.genreSelector = ElementSelector.empty,
    this.statusSelector = ElementSelector.empty,
    this.descriptionSelector = ElementSelector.empty,
    this.chaptersSelector = ElementSelector.empty,
    this.chapterIdSelector = ElementSelector.empty,
    this.chapterImageSelector = ElementSelector.empty,
    this.chapterNameSelector = ElementSelector.empty,
    this.chapterImagesByIdSelector = ElementSelector.empty,
    this.chapterTitleByIdSelector = ElementSelector.empty,
    this.chapterImagesByIdSelectionSelector = ElementSelector.empty,
  });

  factory ScraperConfig.fromJson(Map<String, dynamic> json) {
    final detail = json['detail'] as Map<String, dynamic>? ?? {};
    final chapterByIdSelectors =
        json['chapter_by_id_selectors'] as Map<String, dynamic>? ?? {};
    // log("chapterByIdSelectors is $chapterByIdSelectors");
    return ScraperConfig(
      titleSelector: ElementSelector.fromJson(json['title_selector'] ?? {}),
      thumbnailSelector:
          ElementSelector.fromJson(json['thumbnail_selector'] ?? {}),
      contentUrlSelector:
          ElementSelector.fromJson(json['content_url_selector'] ?? {}),
      contentSelector: ElementSelector.fromJson(json['content_selector'] ?? {}),
      videoSelector: ElementSelector.fromJson(json['video_selector'] ?? {}),
      previewSelector: ElementSelector.fromJson(json['preview_selector'] ?? {}),
      qualitySelector: ElementSelector.fromJson(json['quality_selector'] ?? {}),
      timeSelector: ElementSelector.fromJson(json['time_selector'] ?? {}),
      viewsSelector: ElementSelector.fromJson(json['views_selector'] ?? {}),
      durationSelector:
          ElementSelector.fromJson(json['duration_selector'] ?? {}),
      watchingLinkSelector:
          ElementSelector.fromJson(json['watching_link_selector'] ?? {}),
      keywordsSelector:
          ElementSelector.fromJson(json['keywords_selector'] ?? {}),
      similarContentSelector:
          ElementSelector.fromJson(json['similar_content_selector'] ?? {}),
      detailSelector: ElementSelector.fromJson(json['detail_selector'] ?? {}),
      genreSelector: ElementSelector.fromJson(detail['genre_selector'] ?? {}),
      statusSelector: ElementSelector.fromJson(detail['status_selector'] ?? {}),
      descriptionSelector:
          ElementSelector.fromJson(detail['description_selector'] ?? {}),
      chaptersSelector:
          ElementSelector.fromJson(detail['chapters_selector'] ?? {}),
      chapterIdSelector:
          ElementSelector.fromJson(detail['chapter_id_selector'] ?? {}),
      chapterImageSelector:
          ElementSelector.fromJson(detail['chapter_image_selector'] ?? {}),
      chapterNameSelector:
          ElementSelector.fromJson(detail['chapter_name_selector'] ?? {}),
      chapterImagesByIdSelector: ElementSelector.fromJson(
          chapterByIdSelectors['image_selector'] ?? {}),
      chapterTitleByIdSelector: ElementSelector.fromJson(
          chapterByIdSelectors['title_selector'] ?? {}),
      chapterImagesByIdSelectionSelector:
          ElementSelector.fromJson(chapterByIdSelectors['main_selector'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    final detail = {
      if (genreSelector != ElementSelector.empty)
        'genre_selector': genreSelector.toJson(),
      if (statusSelector != ElementSelector.empty)
        'status_selector': statusSelector.toJson(),
      if (descriptionSelector != ElementSelector.empty)
        'description_selector': descriptionSelector.toJson(),
      if (chaptersSelector != ElementSelector.empty)
        'chapters_selector': chaptersSelector.toJson(),
      if (chapterIdSelector != ElementSelector.empty)
        'chapter_id_selector': chapterIdSelector.toJson(),
      if (chapterImageSelector != ElementSelector.empty)
        'chapter_image_selector': chapterImageSelector.toJson(),
      if (chapterNameSelector != ElementSelector.empty)
        'chapter_name_selector': chapterNameSelector.toJson(),
    };

    final chapterByIdSelectors = {
      if (chapterImagesByIdSelector != ElementSelector.empty)
        'image_selector': chapterImagesByIdSelector.toJson(),
      if (chapterTitleByIdSelector != ElementSelector.empty)
        'title_selector': chapterTitleByIdSelector.toJson(),
      if (chapterImagesByIdSelectionSelector != ElementSelector.empty)
        'main_selector': chapterImagesByIdSelectionSelector.toJson(),
    };

    return {
      'title_selector': titleSelector.toJson(),
      'thumbnail_selector': thumbnailSelector.toJson(),
      'content_url_selector': contentUrlSelector.toJson(),
      if (contentSelector != ElementSelector.empty)
        'content_selector': contentSelector.toJson(),
      if (videoSelector != ElementSelector.empty)
        'video_selector': videoSelector.toJson(),
      if (previewSelector != ElementSelector.empty)
        'preview_selector': previewSelector.toJson(),
      if (qualitySelector != ElementSelector.empty)
        'quality_selector': qualitySelector.toJson(),
      if (timeSelector != ElementSelector.empty)
        'time_selector': timeSelector.toJson(),
      if (viewsSelector != ElementSelector.empty)
        'views_selector': viewsSelector.toJson(),
      if (durationSelector != ElementSelector.empty)
        'duration_selector': durationSelector.toJson(),
      if (watchingLinkSelector != ElementSelector.empty)
        'watching_link_selector': watchingLinkSelector.toJson(),
      if (keywordsSelector != ElementSelector.empty)
        'keywords_selector': keywordsSelector.toJson(),
      if (similarContentSelector != ElementSelector.empty)
        'similar_content_selector': similarContentSelector.toJson(),
      if (detailSelector != ElementSelector.empty)
        'detail_selector': detailSelector.toJson(),
      if (detail.isNotEmpty) 'detail': detail,
      if (chapterByIdSelectors.isNotEmpty)
        'chapter_by_id_selectors': chapterByIdSelectors,
    };
  }
}
