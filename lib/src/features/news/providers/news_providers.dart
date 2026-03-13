// Riverpod providers for news feed and state management
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/config/logger.dart';
import 'package:mini_news_intelligence/src/data/datasources/local/hive_local_service.dart';
import 'package:mini_news_intelligence/src/data/datasources/remote/news_api_service.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/data/repositories/news_repository_impl.dart';
import 'package:mini_news_intelligence/src/providers.dart';
import 'package:mini_news_intelligence/src/shared/utils/debouncer.dart';

final newsApiServiceProvider = Provider<NewsApiService>((ref) {
  final client = ref.read(httpClientProvider);
  return NewsApiService(client: client);
});

final hiveLocalServiceProvider = Provider<HiveLocalService>((ref) {
  return HiveLocalService();
});

final connServPro = connectivityServiceProvider;

final newsRepositoryProvider = Provider<NewsRepositoryImpl>((ref) {
  final api = ref.read(newsApiServiceProvider);
  final local = ref.read(hiveLocalServiceProvider);
  final connectivity = ref.read(connServPro);
  return NewsRepositoryImpl(api: api, local: local, connectivity: connectivity);
});

class NewsState {
  final List<ArticleModel> articles;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String selectedCategory;

  NewsState({
    required this.articles,
    required this.page,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
    required this.selectedCategory,
  });

  factory NewsState.initial() {
    return NewsState(
      articles: [],
      page: 1,
      isLoading: false,
      isLoadingMore: false,
      hasMore: true,
      error: null,
      selectedCategory: 'business',
    );
  }

  NewsState copyWith({
    List<ArticleModel>? articles,
    int? page,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? selectedCategory,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NewsRepositoryImpl repository;
  final Debouncer debouncer = Debouncer(const Duration(milliseconds: 300));

  NewsNotifier(this.repository) : super(NewsState.initial());

  Future<void> loadInitial(String category) async {
    state = state.copyWith(
        isLoading: true, error: null, selectedCategory: category, page: 1);
    try {
      Logger.info("loadInitial", "getTopHeadlines() called");
      final articles = await repository.getTopHeadlines(
          category: category, page: 1, pageSize: 20, forceRefresh: false);
      state = state.copyWith(
          articles: articles,
          isLoading: false,
          hasMore: articles.length >= 20,
          page: 1);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    final next = state.page + 1;
    try {
      final articles = await repository.getTopHeadlines(
          category: state.selectedCategory,
          page: next,
          pageSize: 20,
          forceRefresh: false);
      final merged = [...state.articles, ...articles];
      state = state.copyWith(
          articles: merged,
          page: next,
          isLoadingMore: false,
          hasMore: articles.length >= 20);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final articles = await repository.getTopHeadlines(
          category: state.selectedCategory,
          page: 1,
          pageSize: 20,
          forceRefresh: true);
      state = state.copyWith(
          articles: articles,
          isLoading: false,
          page: 1,
          hasMore: articles.length >= 20);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleFavorite(ArticleModel article) async {
    try {
      final updated = await repository.toggleFavorite(article);
      final updatedList =
          state.articles.map((a) => a.id == updated.id ? updated : a).toList();
      state = state.copyWith(articles: updatedList);
    } catch (e) {
      // swallow error but log
    }
  }
}

final newsNotifierProvider =
    StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  final repo = ref.read(newsRepositoryProvider);
  return NewsNotifier(repo);
});
