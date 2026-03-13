// Local persistence service handling Hive boxes
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/data/models/user_model.dart';

class HiveLocalService {
  final Box<ArticleModel> favoritesBox = Hive.box<ArticleModel>(HiveBoxes.favorites);
  final Box<Map> cacheBox = Hive.box<Map>(HiveBoxes.cache);
  final Box<UserModel> authBox = Hive.box<UserModel>(HiveBoxes.auth);

  List<ArticleModel> getFavorites() {
    final items = favoritesBox.values.toList();
    items.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return items;
  }

  Future<void> saveFavorite(ArticleModel article) async {
    final toSave = article.copyWith(isFavorite: true);
    await favoritesBox.put(article.id, toSave);
  }

  Future<void> removeFavorite(String articleId) async {
    await favoritesBox.delete(articleId);
  }

  bool isFavorite(String articleId) {
    return favoritesBox.containsKey(articleId);
  }

  Future<void> persistAuth(UserModel user) async {
    await authBox.put('user', user);
  }

  Future<void> clearAuth() async {
    await authBox.clear();
  }

  Future<void> cacheArticles(String cacheKey, List<ArticleModel> articles, DateTime fetchedAt) async {
    final data = {
      'fetchedAt': fetchedAt.toIso8601String(),
      'articles': articles.map((e) => e.toJson()).toList(),
    };
    await cacheBox.put(cacheKey, data);
  }

  List<ArticleModel> getCachedArticles(String cacheKey) {
    final data = cacheBox.get(cacheKey);
    if (data == null) return [];
    final list = data['articles'] as List<dynamic>? ?? [];
    final parsed = list.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return ArticleModel.fromJson(map, category: map['category'] as String?);
    }).toList();
    return parsed;
  }
}
