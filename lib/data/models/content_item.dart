import 'dart:developer';

import 'content_source.dart';

class ContentItem {
  final String title;
  final String duration;
  final String preview;
  final String quality;
  final String time;
  final String thumbnailUrl;
  final String contentUrl;
  final String? videoUrl;
  final String views;
  final ContentSource source;
  final DetailModel? detailContent;
  final List<Chapter>? chapterImagesById;
  final DateTime scrapedAt;

  final DateTime addedAt;

  ContentItem({
    required this.title,
    this.duration = '0:00',
    this.preview = '',
    this.quality = "HD",
    this.time = "0:00",
    required this.thumbnailUrl,
    required this.contentUrl,
    this.videoUrl = '',
    this.views = "0",
    required this.source,
    required this.scrapedAt,
    this.detailContent,
    this.chapterImagesById,
    required this.addedAt,
  });

  ContentItem copyWith({
    String? title,
    String? duration,
    String? preview,
    String? quality,
    String? time,
    String? thumbnailUrl,
    String? contentUrl,
    String? videoUrl,
    String? views,
    ContentSource? source,
    DetailModel? detailContent,
    List<Chapter>? chapterImagesById,
    DateTime? scrapedAt,
    DateTime? addedAt,
    String? genre,
    String? status,
    String? chapterCount,
    String? discription,
    String? chapterId,
    String? chapterImages,
    String? user,
    String? likes,
    String? comments,
  }) {
    return ContentItem(
      title: title ?? this.title,
      duration: duration ?? this.duration,
      preview: preview ?? this.preview,
      quality: quality ?? this.quality,
      time: time ?? this.time,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      contentUrl: contentUrl ?? this.contentUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      views: views ?? this.views,
      source: source ?? this.source,
      scrapedAt: scrapedAt ?? this.scrapedAt,
      detailContent: detailContent ?? this.detailContent,
      chapterImagesById: chapterImagesById ?? this.chapterImagesById,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  /// Convert object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'duration': duration,
      'preview': preview,
      'quality': quality,
      'time': time,
      'thumbnailUrl': thumbnailUrl,
      'contentUrl': contentUrl,
      'videoUrl': videoUrl,
      'views': views,
      'source': source.toJson(), // Make sure ContentSource has toJson()
      'detailContent': detailContent!.toJson(),
      'chapterImagesById': chapterImagesById!.map((c) => c.toJson()),
      'scrapedAt': scrapedAt.toIso8601String(),

      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create object from JSON map
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    // log("jsonjsonjson is $json");
    return ContentItem(
      title: json['title'],
      duration: json['duration'] ?? '0:00',
      preview: json['preview'] ?? '',
      quality: json['quality'] ?? 'HD',
      time: json['time'] ?? '0:00',
      thumbnailUrl: json['thumbnailUrl'],
      contentUrl: json['contentUrl'],
      videoUrl: json['videoUrl'] ?? '',
      views: json['views'] ?? '0',
      source: ContentSource.fromJson(json['source']), // Requires fromJson()
      detailContent: DetailModel.fromJson(
          json['detailContent'] ?? {}), // Requires fromJson()
      chapterImagesById: List<Chapter>.from(json['chapterImagesById'])
          .map((c) => c)
          .toList(), // Requires fromJson()
      scrapedAt: DateTime.parse(json['scrapedAt']),

      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}

class DetailModel {
  DetailModel({
    required this.discription,
    required this.genre,
    required this.status,
    required this.chapterSelector,
    this.chapter,
  });

  final String? discription;
  final String? genre;
  final String? status;
  final String? chapterSelector;
  final List<Chapter>? chapter;

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      discription: json["discription"],
      genre: json["genre"],
      status: json["status"],
      chapterSelector: json["chapterSelector"],
      chapter: json["chapter"] == null
          ? []
          : List<Chapter>.from(
              json["chapter"]!.map((x) => Chapter.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "discription": discription,
        "genre": genre,
        "status": status,
        "chapterSelector": chapterSelector,
        "chapter": chapter!.map((x) => x.toJson()).toList(),
      };
}

class Chapter {
  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.chapterImage,
  });

  final String? chapterId;
  final String? chapterName;
  final String? chapterImage;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json["chapterId"],
      chapterName: json["chapterName"],
      chapterImage: json["chapterImage"],
    );
  }

  Map<String, dynamic> toJson() => {
        "chapterId": chapterId,
        "chapterName": chapterName,
        "chapterImage": chapterImage,
      };
}
