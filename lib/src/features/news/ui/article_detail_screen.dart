// Article detail screen with open in browser and favorite toggle
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/features/news/providers/news_providers.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final ArticleModel article;
  const ArticleDetailScreen({Key? key, required this.article})
      : super(key: key);

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  late ArticleModel _article;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
  }

  Future<void> _openUrl() async {
    final url = Uri.tryParse(_article.url);
    if (url == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Invalid URL')));
      return;
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open URL')));
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _processing = true);
    try {
      final updated = await ref
          .read(newsNotifierProvider.notifier)
          .toggleFavorite(_article);
      // newsNotifier returns void; retrieve updated state to update local article
      final current = ref
          .read(newsNotifierProvider)
          .articles
          .firstWhere((a) => a.id == _article.id, orElse: () => _article);
      setState(() => _article = current);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorite: $e')));
    } finally {
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final published =
        DateFormat.yMMMMd().add_jm().format(_article.publishedAt.toLocal());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: Icon(
                _article.isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: _processing ? null : _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openUrl,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _article.imageUrl != null
                ? Image.network(_article.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Image.network(
                        'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=60',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover);
                  })
                : const SizedBox.shrink(),
            const SizedBox(height: 12),
            Text(_article.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                if (_article.sourceName != null)
                  Text(_article.sourceName!,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(published, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
                _article.content ??
                    _article.description ??
                    'No content available',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _openUrl,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open in Browser'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _processing ? null : _toggleFavorite,
                  icon: Icon(_article.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  label: Text(_article.isFavorite ? 'Unsave' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
