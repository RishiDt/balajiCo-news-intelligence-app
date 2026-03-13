// Favorites screen showing persisted saved articles
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mini_news_intelligence/src/core/app_routes.dart';
import 'package:mini_news_intelligence/src/features/news/providers/news_providers.dart';
import 'package:mini_news_intelligence/src/shared/widgets/article_tile.dart';
import 'package:mini_news_intelligence/src/shared/widgets/error_retry_widget.dart';
import 'package:mini_news_intelligence/src/shared/widgets/loading_widget.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      await Future.delayed(Duration.zero, () async {
        if (!mounted) return;
        await ref.read(newsNotifierProvider.notifier).refresh();
      });
      // await ref.read(newsNotifierProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsNotifierProvider);
    final favorites = state.articles.where((a) => a.isFavorite).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Clear all favorites?'),
                        content:
                            const Text('This will remove all saved articles.'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(_, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () => Navigator.pop(_, true),
                              child: const Text('Clear')),
                        ],
                      ),
                    ) ??
                    false;
                if (confirmed) {
                  final repo = ref.read(newsRepositoryProvider);
                  final favs = await repo.getFavorites();
                  for (final f in favs) {
                    await repo.toggleFavorite(f);
                  }
                  await _loadFavorites();
                }
              },
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: _loading
          ? const Center(child: LoadingWidget(message: 'Loading favorites...'))
          : _error != null
              ? ErrorRetryWidget(message: _error!, onRetry: _loadFavorites)
              : favorites.isEmpty
                  ? const Center(child: Text('No favorites yet'))
                  : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final a = favorites[index];
                        return Dismissible(
                          key: Key(a.id),
                          background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16),
                              child: const Icon(Icons.delete,
                                  color: Colors.white)),
                          secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete,
                                  color: Colors.white)),
                          onDismissed: (_) async {
                            await ref
                                .read(newsNotifierProvider.notifier)
                                .toggleFavorite(a);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Removed from favorites')));
                          },
                          child: ArticleTile(
                            article: a,
                            isFavorite: true,
                            onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.routeArticleDetail,
                                arguments: a),
                            onFavoriteToggle: () async {
                              await ref
                                  .read(newsNotifierProvider.notifier)
                                  .toggleFavorite(a);
                              await _loadFavorites();
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
