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
  final String? cdn;
  final Map? body;
  final Map? header;
  final bool? hasEpisodes;
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
    this.cdn = '',
    this.body = const {},
    this.header = const {},
    this.hasEpisodes = false,
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
      cdn: json['cdn'] ?? '',
      body: json['body'] ?? {},
      header: json['header'] ?? {},
      hasEpisodes: json['hasEpisodes'] ?? false,
      pageIncriment: json['pageIncriment'] ?? '',
      query: Map<String, String>.from(json['query'] ?? {}),
      config: json['config'] == null
          ? null
          : ScraperConfig.fromJson(json['config']),
      enabled: json['enabled'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'searchUrl': searchUrl,
      'type': type,
      'decodeType': decodeType,
      'NSFW': nsfw,
      'getType': getType,
      'isPreview': isPreview,
      'isEmbed': isEmbed,
      'name': name,
      'icon': icon,
      'pageType': pageType,
      'pageIncriment': pageIncriment,
      'cdn': cdn,
      'body': body,
      'header': header,
      'hasEpisodes': hasEpisodes,
      'query': query,
      'config': config?.toJson(),
      'enabled': enabled,
    };
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
