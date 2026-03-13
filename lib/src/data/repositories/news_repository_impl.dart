// Repository implementation that composes remote and local data sources
import 'package:mini_news_intelligence/src/core/network/network_exceptions.dart';
import 'package:mini_news_intelligence/src/data/datasources/local/hive_local_service.dart';
import 'package:mini_news_intelligence/src/data/datasources/remote/news_api_service.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/shared/services/connectivity_service.dart';

abstract class NewsRepository {
  Future<List<ArticleModel>> getTopHeadlines({required String category, required int page, required int pageSize, bool forceRefresh});
  Future<List<ArticleModel>> searchArticles({required String query, required int page, required int pageSize});
  Future<List<ArticleModel>> getFavorites();
  Future<ArticleModel> toggleFavorite(ArticleModel article);
  Future<bool> isFavorite(String articleId);
}

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiService api;
  final HiveLocalService local;
  final ConnectivityService connectivity;

  NewsRepositoryImpl({required this.api, required this.local, required this.connectivity});

  @override
  Future<List<ArticleModel>> getTopHeadlines({required String category, required int page, required int pageSize, bool forceRefresh = false}) async {
    final cacheKey = 'top_$category\_page_$page';
    final connected = await connectivity.isConnected();
    if (!forceRefresh && !connected) {
      // return cached if network not available
      final cached = local.getCachedArticles(cacheKey);
      return _syncFavorites(cached);
    }
    try {
      final json = await api.fetchTopHeadlines(category: category, page: page, pageSize: pageSize);
      if (json['status'] != 'ok') {
        throw ApiException('API returned non-ok status');
      }
      final parsed = api.parseArticles(json, category: category);
      await local.cacheArticles(cacheKey, parsed, DateTime.now().toUtc());
      return _syncFavorites(parsed);
    } on Exception catch (e) {
      // On failure, fallback to cache if available
      final cached = local.getCachedArticles(cacheKey);
      if (cached.isNotEmpty) {
        return _syncFavorites(cached);
      }
      rethrow;
    }
  }

  @override
  Future<List<ArticleModel>> searchArticles({required String query, required int page, required int pageSize}) async {
    try {
      final json = await api.searchArticles(query, page: page, pageSize: pageSize);
      if (json['status'] != 'ok') {
        throw ApiException('API returned non-ok status');
      }
      final parsed = api.parseArticles(json);
      return _syncFavorites(parsed);
    } on Exception {
      rethrow;
    }
  }

  @override
  Future<List<ArticleModel>> getFavorites() async {
    final favs = local.getFavorites();
    return favs;
  }

  @override
  Future<ArticleModel> toggleFavorite(ArticleModel article) async {
    final isFav = local.isFavorite(article.id);
    if (isFav) {
      await local.removeFavorite(article.id);
      return article.copyWith(isFavorite: false);
    } else {
      await local.saveFavorite(article.copyWith(isFavorite: true));
      return article.copyWith(isFavorite: true);
    }
  }

  @override
  Future<bool> isFavorite(String articleId) async {
    return local.isFavorite(articleId);
  }

  List<ArticleModel> _syncFavorites(List<ArticleModel> articles) {
    final favs = local.getFavorites();
    final favIds = favs.map((e) => e.id).toSet();
    return articles.map((a) => a.copyWith(isFavorite: favIds.contains(a.id))).toList();
  }
}
