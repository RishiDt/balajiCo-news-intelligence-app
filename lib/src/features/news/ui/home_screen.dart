// Home screen with category chips, paginated list, pull-to-refresh
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/core/app_routes.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/features/news/providers/news_providers.dart';
import 'package:mini_news_intelligence/src/shared/widgets/article_tile.dart';
import 'package:mini_news_intelligence/src/shared/widgets/error_retry_widget.dart';
import 'package:mini_news_intelligence/src/shared/widgets/loading_widget.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = SUPPORTED_CATEGORIES.first;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      ref.read(newsNotifierProvider.notifier).loadInitial(_selectedCategory);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 300) {
      ref.read(newsNotifierProvider.notifier).loadNextPage();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(newsNotifierProvider.notifier).loadInitial(category);
    });
  }

  Future<void> _onRefresh() =>
      ref.read(newsNotifierProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mini News Intelligence'),
          actions: [
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.routeSearch),
                icon: const Icon(Icons.search)),
            IconButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.routeFavorites),
                icon: const Icon(Icons.favorite)),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.routeLogin,
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => const [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 56,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final cat = SUPPORTED_CATEGORIES[index];
                  final selected = cat == _selectedCategory;
                  return ChoiceChip(
                    label: Text(cat.capitalize()),
                    selected: selected,
                    onSelected: (_) => _onCategoryChanged(cat),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: SUPPORTED_CATEGORIES.length,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: Builder(builder: (context) {
                  if (state.isLoading && state.articles.isEmpty) {
                    return const Center(
                        child: LoadingWidget(message: 'Loading news...'));
                  }
                  if (state.error != null && state.articles.isEmpty) {
                    return ErrorRetryWidget(
                        message: state.error!,
                        onRetry: () => ref
                            .read(newsNotifierProvider.notifier)
                            .loadInitial(_selectedCategory));
                  }
                  if (state.articles.isEmpty) {
                    return Center(
                        child: Text('No articles yet. Pull to refresh.'));
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.articles.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.articles.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final article = state.articles[index];
                      return ArticleTile(
                        article: article,
                        isFavorite: article.isFavorite,
                        onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.routeArticleDetail,
                            arguments: article),
                        onFavoriteToggle: () async {
                          await ref
                              .read(newsNotifierProvider.notifier)
                              .toggleFavorite(article);
                        },
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
