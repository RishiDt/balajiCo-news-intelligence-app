// Remote service for interacting with public news API (NewsAPI.org compatible)
import 'package:mini_news_intelligence/src/config/logger.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/core/network/http_client.dart';
import 'package:mini_news_intelligence/src/core/network/network_exceptions.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';

class NewsApiService {
  final HttpClient client;

  NewsApiService({required this.client});

  Future<Map<String, dynamic>> _fetch(
      String endpoint, Map<String, String> params) async {
    final url = '$API_BASE_URL/$endpoint';
    final merged = {
      'apiKey': API_KEY,
      ...params,
    };
    try {
      final json = await client.getJson(url, params: merged);

      return json;
    } on ApiException catch (e) {
      throw e;
    } on NetworkException catch (e) {
      throw e;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  Future<Map<String, dynamic>> fetchTopHeadlines({
    String category = 'business',
    int page = 1,
    int pageSize = DEFAULT_PAGE_SIZE,
    String country = 'us',
  }) async {
    final result = await _fetch('top-headlines', {
      'category': category,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'country': country,
    });
    return result;
  }

  Future<Map<String, dynamic>> searchArticles(String query,
      {int page = 1, int pageSize = DEFAULT_PAGE_SIZE}) async {
    if (query.trim().isEmpty) {
      throw ApiException('Query cannot be empty');
    }
    final result = await _fetch('everything', {
      'q': query,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'sortBy': 'publishedAt',
    });
    return result;
  }

  // Helper to parse articles list
  List<ArticleModel> parseArticles(Map<String, dynamic> json,
      {String? category}) {
    final articles = <ArticleModel>[];
    final items = json['articles'];
    if (items is List) {
      for (final item in items) {
        try {
          final map = item as Map<String, dynamic>;
          final article = ArticleModel.fromJson(map, category: category);
          articles.add(article);
        } catch (e) {
          // skip malformed
        }
      }
    }
    return articles;
  }
}
