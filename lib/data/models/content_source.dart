import 'package:watching_app_2/data/models/scraper_config.dart';

class ContentSource {
  final String url;
  final String searchUrl;
  final String type;
  final String decodeType;
  final String nsfw;
  final String getType;
  final String isPreview;
  final String isEmbed;
  final String name;
  final String icon;
  final String pageType;
  final String pageIncriment;
  final Map<String, String> query;
  final ScraperConfig? config;
  final bool? enabled;

  ContentSource({
    required this.url,
    required this.searchUrl,
    required this.type,
    required this.decodeType,
    required this.nsfw,
    required this.getType,
    required this.isPreview,
    required this.isEmbed,
    required this.name,
    required this.icon,
    required this.pageType,
    this.pageIncriment = '',
    required this.query,
    this.config,
    this.enabled,
  });

  factory ContentSource.fromJson(Map<String, dynamic> json) {
    return ContentSource(
      url: json['url'] ?? '',
      searchUrl: json['searchUrl'] ?? '',
      type: json['type'] ?? '',
      decodeType: json['decodeType'] ?? '',
      nsfw: json['NSFW'] ?? '',
      getType: json['getType'] ?? '',
      isPreview: json['isPreview'] ?? '',
      isEmbed: json['isEmbed'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      pageType: json['pageType'] ?? '',
      pageIncriment: json['pageIncriment'] ?? '',
      query: Map<String, String>.from(json['query'] ?? {}),
      config: json["config"] == null
          ? null
          : ScraperConfig.fromJson(json["config"]),
      enabled: json["enabled"],
    );
  }

  String getQueryUrl(String queryType, int page) {
    return url +
        queryType
            .replaceAll('{page}', page.toString())
            .replaceAll('?{filter}', '');
  }

  String getSearchUrl(String search, int page) {
    return searchUrl
        .replaceAll('{search}', search)
        .replaceAll('?{filter}', '')
        .replaceAll('{page}', page.toString());
  }
}

// class Config {
//   Config({
//     required this.titleSelector,
//     required this.thumbnailSelector,
//     required this.contentUrlSelector,
//     required this.qualitySelector,
//     required this.timeSelector,
//     required this.durationSelector,
//     required this.previewSelector,
//     required this.watchingLinkSelector,
//     required this.keywordsSelector,
//     required this.similarContentSelector,
//     required this.videoSelector,
//     required this.contentSelector,
//   });

//   final ContentSelectorClass? titleSelector;
//   final ContentSelectorClass? thumbnailSelector;
//   final ContentSelectorClass? contentUrlSelector;
//   final ContentSelectorClass? qualitySelector;
//   final ContentSelectorClass? timeSelector;
//   final ContentSelectorClass? durationSelector;
//   final ContentSelectorClass? previewSelector;
//   final ContentSelectorClass? watchingLinkSelector;
//   final ContentSelectorClass? keywordsSelector;
//   final ContentSelectorClass? similarContentSelector;
//   final ContentSelectorClass? videoSelector;
//   final ContentSelectorClass? contentSelector;

//   factory Config.fromJson(Map<String, dynamic> json) {
//     return Config(
//       titleSelector: json["title_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["title_selector"]),
//       thumbnailSelector: json["thumbnail_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["thumbnail_selector"]),
//       contentUrlSelector: json["content_url_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["content_url_selector"]),
//       qualitySelector: json["quality_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["quality_selector"]),
//       timeSelector: json["time_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["time_selector"]),
//       durationSelector: json["duration_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["duration_selector"]),
//       previewSelector: json["preview_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["preview_selector"]),
//       watchingLinkSelector: json["watching_link_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["watching_link_selector"]),
//       keywordsSelector: json["keywords_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["keywords_selector"]),
//       similarContentSelector: json["similar_content_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["similar_content_selector"]),
//       videoSelector: json["video_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["video_selector"]),
//       contentSelector: json["content_selector"] == null
//           ? null
//           : ContentSelectorClass.fromJson(json["content_selector"]),
//     );
//   }
// }

// class ContentSelectorClass {
//   ContentSelectorClass({
//     required this.selector,
//     required this.attribute,
//     required this.customExtraction,
//   });

//   final String? selector;
//   final String? attribute;
//   final bool? customExtraction;

//   factory ContentSelectorClass.fromJson(Map<String, dynamic> json) {
//     return ContentSelectorClass(
//       selector: json["selector"],
//       attribute: json["attribute"],
//       customExtraction: json["custom_extraction"],
//     );
//   }
// }
