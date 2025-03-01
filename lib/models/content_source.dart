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
