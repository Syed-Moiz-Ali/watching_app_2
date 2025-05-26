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
  DetailModel? detailContent;
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
      'source': source.toJson(),
      'detailContent': detailContent?.toJson(), // Handle null case
      'chapterImagesById':
          chapterImagesById?.map((c) => c.toJson()).toList(), // Convert to List
      'scrapedAt': scrapedAt.toIso8601String(),
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create object from JSON map
  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      title: json['title'] as String,
      duration: json['duration'] as String? ?? '0:00',
      preview: json['preview'] as String? ?? '',
      quality: json['quality'] as String? ?? 'HD',
      time: json['time'] as String? ?? '0:00',
      thumbnailUrl: json['thumbnailUrl'] as String,
      contentUrl: json['contentUrl'] as String,
      videoUrl: json['videoUrl'] as String? ?? '',
      views: json['views'] as String? ?? '0',
      source: ContentSource.fromJson(json['source'] as Map<String, dynamic>),
      detailContent: json['detailContent'] != null
          ? DetailModel.fromJson(json['detailContent'] as Map<String, dynamic>)
          : null,
      chapterImagesById: json['chapterImagesById'] != null
          ? (json['chapterImagesById'] as List<dynamic>)
              .map((c) => Chapter.fromJson(c as Map<String, dynamic>))
              .toList()
          : null,
      scrapedAt: DateTime.parse(json['scrapedAt'] as String),
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }
}

class DetailModel {
  DetailModel({
    this.discription,
    this.genre,
    this.status,
    this.chapterSelector,
    this.chapter,
  });

  final String? discription;
  final String? genre;
  final String? status;
  final String? chapterSelector;
  final List<Chapter>? chapter;

  factory DetailModel.fromJson(Map<String, dynamic> json) {
    return DetailModel(
      discription: json['discription'] as String?,
      genre: json['genre'] as String?,
      status: json['status'] as String?,
      chapterSelector: json['chapterSelector'] as String?,
      chapter: json['chapter'] == null
          ? null
          : (json['chapter'] as List<dynamic>)
              .map((x) => Chapter.fromJson(x as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'discription': discription,
        'genre': genre,
        'status': status,
        'chapterSelector': chapterSelector,
        'chapter': chapter?.map((x) => x.toJson()).toList(),
      };
}

class Chapter {
  Chapter({
    required this.chapterId,
    required this.chapterName,
    this.source,
    required this.chapterImage,
  });

  final String? chapterId;
  final String? chapterName;
  ContentSource? source;
  final String? chapterImage;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as String?,
      chapterName: json['chapterName'] as String?,
      source: json['source'] != null
          ? ContentSource.fromJson(json['source'] as Map<String, dynamic>)
          : null,
      chapterImage: json['chapterImage'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'chapterName': chapterName,
        'source': source?.toJson(),
        'chapterImage': chapterImage,
      };
}
