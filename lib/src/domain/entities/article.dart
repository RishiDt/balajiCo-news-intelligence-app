// Domain entity for Article (mirrors ArticleModel)
import 'package:mini_news_intelligence/src/data/models/article_model.dart';

class Article {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? sourceName;
  final String? author;
  final String? category;
  final bool isFavorite;

  Article({
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

  factory Article.fromModel(ArticleModel model) {
    return Article(
      id: model.id,
      title: model.title,
      description: model.description,
      content: model.content,
      url: model.url,
      imageUrl: model.imageUrl,
      publishedAt: model.publishedAt,
      sourceName: model.sourceName,
      author: model.author,
      category: model.category,
      isFavorite: model.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
