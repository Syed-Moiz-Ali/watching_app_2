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

  Map<String, dynamic> toJson() => {
        if (selector != null) 'selector': selector,
        if (attribute != null) 'attribute': attribute,
        if (customExtraction != null) 'custom_extraction': customExtraction,
      };
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
  final ElementSelector? chaptersSelector;
  final ElementSelector? chapterIdSelector;
  final ElementSelector? chapterImageSelector;
  final ElementSelector? chapterNameSelector;
  final ElementSelector? chapterImagesByIdSelectionSelector;
  final ElementSelector? chapterImagesByIdSelector;

  final ElementSelector? discriptionSelector;

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
    this.chapterIdSelector,
    this.chapterImageSelector,
    this.discriptionSelector,
    this.chaptersSelector,
    this.chapterNameSelector,
    this.chapterImagesByIdSelector,
    this.chapterImagesByIdSelectionSelector,
  });

  factory ScraperConfig.fromJson(Map<String, dynamic> json) {
    // Safely access the 'detail' map, default to empty map if null
    final detail = json['detail'] as Map<String, dynamic>? ?? {};

    return ScraperConfig(
      titleSelector: ElementSelector.fromJson(json['title_selector'] ?? {}),
      thumbnailSelector:
          ElementSelector.fromJson(json['thumbnail_selector'] ?? {}),
      contentUrlSelector:
          ElementSelector.fromJson(json['content_url_selector'] ?? {}),
      contentSelector: json['content_selector'] != null
          ? ElementSelector.fromJson(json['content_selector'])
          : ElementSelector(selector: ''),
      videoSelector: json['video_selector'] != null
          ? ElementSelector.fromJson(json['video_selector'])
          : ElementSelector(selector: ''),
      previewSelector: json['preview_selector'] != null
          ? ElementSelector.fromJson(json['preview_selector'])
          : ElementSelector(selector: ''),
      qualitySelector: json['quality_selector'] != null
          ? ElementSelector.fromJson(json['quality_selector'])
          : ElementSelector(selector: ''),
      timeSelector: json['time_selector'] != null
          ? ElementSelector.fromJson(json['time_selector'])
          : ElementSelector(selector: ''),
      viewsSelector: json['views_selector'] != null
          ? ElementSelector.fromJson(json['views_selector'])
          : ElementSelector(selector: ''),
      durationSelector: json['duration_selector'] != null
          ? ElementSelector.fromJson(json['duration_selector'])
          : ElementSelector(selector: ''),
      watchingLinkSelector: json['watching_link_selector'] != null
          ? ElementSelector.fromJson(json['watching_link_selector'])
          : ElementSelector(selector: ''),
      keywordsSelector: json['keywords_selector'] != null
          ? ElementSelector.fromJson(json['keywords_selector'])
          : ElementSelector(selector: ''),
      similarContentSelector: json['similar_content_selector'] != null
          ? ElementSelector.fromJson(json['similar_content_selector'])
          : ElementSelector(selector: ''),
      detailSelector: json['detail_selector'] != null
          ? ElementSelector.fromJson(json['detail_selector'])
          : ElementSelector(selector: ''),
      genreSelector: detail['genre_selector'] != null
          ? ElementSelector.fromJson(detail['genre_selector'])
          : ElementSelector(selector: ''),
      statusSelector: detail['status_selector'] != null
          ? ElementSelector.fromJson(detail['status_selector'])
          : ElementSelector(selector: ''),
      chaptersSelector: detail['chapters_selector'] != null
          ? ElementSelector.fromJson(detail['chapters_selector'])
          : ElementSelector(selector: ''),
      chapterIdSelector: detail['chapter_id_selector'] != null
          ? ElementSelector.fromJson(detail['chapter_id_selector'])
          : ElementSelector(selector: ''),
      chapterImageSelector: detail['chapter_image_selector'] != null
          ? ElementSelector.fromJson(detail['chapter_image_selector'])
          : ElementSelector(selector: ''),
      chapterNameSelector: detail['chapter_name_selector'] != null
          ? ElementSelector.fromJson(detail['chapter_name_selector'])
          : ElementSelector(selector: ''),
      discriptionSelector: detail['discription_selector'] != null
          ? ElementSelector.fromJson(detail['discription_selector'])
          : ElementSelector(selector: ''),
      chapterImagesByIdSelector: detail['chapter_images_by_id_selector'] != null
          ? ElementSelector.fromJson(detail['chapter_images_by_id_selector'])
          : ElementSelector(selector: ''),
      chapterImagesByIdSelectionSelector:
          detail['chapter_images_by_id_selection_selector'] != null
              ? ElementSelector.fromJson(
                  detail['chapter_images_by_id_selection_selector'])
              : ElementSelector(selector: ''),
    );
  }
  Map<String, dynamic> toJson() => {
        'title_selector': titleSelector.toJson(),
        'thumbnail_selector': thumbnailSelector.toJson(),
        'content_url_selector': contentUrlSelector.toJson(),
        if (contentSelector != null)
          'content_selector': contentSelector!.toJson(),
        if (videoSelector != null) 'video_selector': videoSelector!.toJson(),
        if (detailSelector != null) 'detail_selector': detailSelector!.toJson(),
        if (previewSelector != null)
          'preview_selector': previewSelector!.toJson(),
        if (qualitySelector != null)
          'quality_selector': qualitySelector!.toJson(),
        if (timeSelector != null) 'time_selector': timeSelector!.toJson(),
        if (viewsSelector != null) 'views_selector': viewsSelector!.toJson(),
        if (durationSelector != null)
          'duration_selector': durationSelector!.toJson(),
        if (watchingLinkSelector != null)
          'watching_link_selector': watchingLinkSelector!.toJson(),
        if (keywordsSelector != null)
          'keywords_selector': keywordsSelector!.toJson(),
        if (similarContentSelector != null)
          'similar_content_selector': similarContentSelector!.toJson(),
        if (genreSelector != null) 'genre_selector': genreSelector!.toJson(),
        if (statusSelector != null) 'status_selector': statusSelector!.toJson(),
        if (chaptersSelector != null)
          'chapters_selector': chaptersSelector!.toJson(),
        if (chapterIdSelector != null)
          'chapter_id_selector': chapterIdSelector!.toJson(),
        if (chapterImageSelector != null)
          'chapter_image_selector': chapterImageSelector!.toJson(),
        if (discriptionSelector != null)
          'discription_selector': discriptionSelector!.toJson(),
        if (chapterNameSelector != null)
          'chapter_name_selector': chapterNameSelector!.toJson(),
        if (chapterNameSelector != null)
          'chapter_images_by_id_selector': chapterImagesByIdSelector!.toJson(),
        if (chapterNameSelector != null)
          'chapter_images_by_id_selection_selector':
              chapterImagesByIdSelectionSelector!.toJson(),
      };
}
