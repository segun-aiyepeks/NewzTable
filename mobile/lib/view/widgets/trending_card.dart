import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class TrendingCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback? onBookmarkTap;
  final bool isBookmarked;

  const TrendingCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookmarkTap,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Featured image
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE9ECEF),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE9ECEF),
                              child: const Icon(Icons.newspaper_rounded, color: Colors.grey, size: 40),
                            ),
                          )
                        : Container(
                            color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE9ECEF),
                            child: const Icon(Icons.newspaper_rounded, color: Colors.grey, size: 40),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // 2. Category tag
                Text(
                  article.topic.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF9EA3AE) : const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 6),

                // 3. Headline
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Source & Metadata row
                Row(
                  children: [
                    PublisherBadge(sourceName: article.sourceName, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      article.sourceName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1A1D20),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '•',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF6C757D) : const Color(0xFF9CA3AF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeago.format(article.publishedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                      ),
                    ),
                    const Spacer(),
                    if (onBookmarkTap != null)
                      GestureDetector(
                        onTap: onBookmarkTap,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 20,
                            color: isBookmarked ? const Color(0xFF1877F2) : (isDark ? const Color(0xFF8E93A0) : const Color(0xFF9CA3AF)),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.more_horiz_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF9CA3AF),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
