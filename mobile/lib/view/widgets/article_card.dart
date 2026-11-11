import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback? onBookMarkTap;
  final bool isBookmarked;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookMarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F222A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
          width: 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Left Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 96,
                    height: 96,
                    child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFEEF0F4),
                              child: const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFEEF0F4),
                              child: const Icon(Icons.newspaper_rounded, color: Colors.grey, size: 28),
                            ),
                          )
                        : Container(
                            color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFEEF0F4),
                            child: const Icon(Icons.newspaper_rounded, color: Colors.grey, size: 28),
                          ),
                  ),
                ),

                const SizedBox(width: 12),

                // 2. Right Article Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Category
                      Text(
                        article.topic.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: isDark ? const Color(0xFF9EA3AE) : const Color(0xFF6B7280),
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Title
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Meta row
                      Row(
                        children: [
                          PublisherBadge(sourceName: article.sourceName, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              article.sourceName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF1A1D20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF6C757D) : const Color(0xFF9CA3AF),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            timeago.format(article.publishedAt, locale: 'en_short'),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                            ),
                          ),
                          const Spacer(),
                          if (onBookMarkTap != null)
                            GestureDetector(
                              onTap: onBookMarkTap,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                  size: 18,
                                  color: isBookmarked
                                      ? const Color(0xFF1877F2)
                                      : (isDark ? const Color(0xFF8E93A0) : const Color(0xFF9CA3AF)),
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.more_horiz_rounded,
                              size: 18,
                              color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF9CA3AF),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
