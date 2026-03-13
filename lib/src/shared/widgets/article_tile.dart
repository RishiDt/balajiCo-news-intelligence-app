// Reusable article tile widget used in lists
import 'package:flutter/material.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/shared/utils/date_utils.dart';

class ArticleTile extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;

  const ArticleTile({
    Key? key,
    required this.article,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.isFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl ?? FALLBACK_IMAGE;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 130,
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(10)),
                child: Image.network(imageUrl,
                    width: 120,
                    height: double.infinity,
                    fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                  return Image.network(FALLBACK_IMAGE,
                      width: 120, height: 100, fit: BoxFit.cover);
                }),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Expanded(
                          child: Text(article.description ?? '',
                              maxLines: 2, overflow: TextOverflow.ellipsis)),
                      Column(
                        spacing: 0.0,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (article.sourceName != null)
                            Container(
                              // margin: const EdgeInsets.only(right: 8),
                              // padding: const EdgeInsets.symmetric(
                              //     horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                article.sourceName!,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          // const Spacer(),
                          Row(
                            children: [
                              Text(DateUtilsHelper.timeAgo(article.publishedAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                              IconButton(
                                onPressed: onFavoriteToggle,
                                icon: Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        isFavorite ? Colors.red : Colors.grey),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
