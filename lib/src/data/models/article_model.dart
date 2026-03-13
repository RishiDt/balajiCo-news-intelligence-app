// Hive-compatible Article model with manual TypeAdapter
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

@HiveType(typeId: 0)
class ArticleModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? content;
  @HiveField(4)
  final String url;
  @HiveField(5)
  final String? imageUrl;
  @HiveField(6)
  final DateTime publishedAt;
  @HiveField(7)
  final String? sourceName;
  @HiveField(8)
  final String? author;
  @HiveField(9)
  final String? category;
  @HiveField(10)
  bool isFavorite;

  ArticleModel({
    required this.id,
    required this.title,
    this.description,
    this.content,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    this.sourceName,
    this.author,
    this.category,
    this.isFavorite = false,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json, {String? category}) {
    // Support multiple API shapes (NewsAPI.org)
    final source = json['source'];
    final String? published =
        json['publishedAt'] ?? json['published_at'] ?? json['pubDate'];
    DateTime parsedDate = DateTime.now();
    try {
      if (published != null) {
        parsedDate = DateTime.parse(published).toUtc();
      }
    } catch (_) {
      parsedDate = DateTime.now().toUtc();
    }

    final url =
        (json['url'] ?? json['link'] ?? json['article_url'] ?? '').toString();
    final title = (json['title'] ?? '').toString();
    final id =
        const Uuid().v5(Uuid.NAMESPACE_URL, url.isNotEmpty ? url : title);

    return ArticleModel(
      id: id,
      title: title,
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: url,
      imageUrl: json['urlToImage'] as String? ?? json['image'] as String?,
      publishedAt: parsedDate,
      sourceName: source is Map
          ? (source['name'] as String?)
          : json['sourceName'] as String?,
      author: json['author'] as String?,
      category: category,
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'url': url,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt.toIso8601String(),
        'sourceName': sourceName,
        'author': author,
        'category': category,
        'isFavorite': isFavorite,
      };

  ArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    String? url,
    String? imageUrl,
    DateTime? publishedAt,
    String? sourceName,
    String? author,
    String? category,
    bool? isFavorite,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      sourceName: sourceName ?? this.sourceName,
      author: author ?? this.author,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ArticleModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

// Manual adapter implementation to avoid build_runner requirement.
class ArticleModelAdapter extends TypeAdapter<ArticleModel> {
  @override
  final int typeId = 0;

  @override
  ArticleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return ArticleModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String?,
      content: fields[3] as String?,
      url: fields[4] as String,
      imageUrl: fields[5] as String?,
      publishedAt: fields[6] as DateTime,
      sourceName: fields[7] as String?,
      author: fields[8] as String?,
      category: fields[9] as String?,
      isFavorite: fields[10] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ArticleModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.publishedAt)
      ..writeByte(7)
      ..write(obj.sourceName)
      ..writeByte(8)
      ..write(obj.author)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.isFavorite);
  }
}
