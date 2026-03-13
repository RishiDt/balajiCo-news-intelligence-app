// Search screen with debounce and pagination
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/data/repositories/news_repository_impl.dart';
import 'package:mini_news_intelligence/src/features/news/providers/news_providers.dart';
import 'package:mini_news_intelligence/src/shared/widgets/article_tile.dart';
import 'package:mini_news_intelligence/src/shared/widgets/loading_widget.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _page = 1;
  String _query = '';
  List<ArticleModel> _results = [];
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadNextPage();
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String value) async {
    _query = value.trim();
    if (_query.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _hasMore = false;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _page = 1;
      _error = null;
    });
    try {
      final repo = ref.read(newsRepositoryProvider);
      final items =
          await repo.searchArticles(query: _query, page: _page, pageSize: 20);
      setState(() {
        _results = items;
        _hasMore = items.length >= 20;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore) return;
    setState(() => _isLoadingMore = true);
    _page += 1;
    try {
      final repo = ref.read(newsRepositoryProvider);
      final items =
          await repo.searchArticles(query: _query, page: _page, pageSize: 20);
      setState(() {
        _results = [..._results, ...items];
        _hasMore = items.length >= 20;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Articles'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'Search news...', prefixIcon: Icon(Icons.search)),
              onChanged: _onChanged,
              onSubmitted: (v) => _performSearch(v),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingWidget(message: 'Searching...'))
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : _results.isEmpty
                        ? const Center(child: Text('No results'))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                _results.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index >= _results.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                );
                              }
                              final article = _results[index];
                              return ArticleTile(
                                article: article,
                                isFavorite: article.isFavorite,
                                onTap: () => Navigator.of(context).pushNamed(
                                    '/article_detail',
                                    arguments: article),
                                onFavoriteToggle: () async {
                                  await ref
                                      .read(newsNotifierProvider.notifier)
                                      .toggleFavorite(article);
                                  setState(() {
                                    _results = _results
                                        .map((a) => a.id == article.id
                                            ? article.copyWith(
                                                isFavorite: !article.isFavorite)
                                            : a)
                                        .toList();
                                  });
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
