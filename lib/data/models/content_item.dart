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
  final DateTime scrapedAt;
  final String genre;
  final String status;
  final String chapterCount;
  final String discription;
  final String chapterId;
  final String chapterImages;
  final String user;
  final String likes;
  final String comments;
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
    this.genre = '',
    this.status = '',
    this.chapterCount = '',
    this.user = '',
    this.likes = '',
    this.comments = '',
    this.discription = '',
    this.chapterId = '',
    this.chapterImages = '',
    required this.addedAt,
  });

  // **Implementing `copyWith` method**
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
    DateTime? scrapedAt,
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
      genre: genre ?? this.genre,
      status: status ?? this.status,
      chapterCount: chapterCount ?? this.chapterCount,
      discription: discription ?? this.discription,
      chapterId: chapterId ?? this.chapterId,
      chapterImages: chapterImages ?? this.chapterImages,
      user: user ?? this.user,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      addedAt: addedAt,
    );
  }
}
