import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/viewmodel/article_view_model.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class ArticleScreen extends StatefulWidget {
  final ArticleModel article;
  final bool isBookmarked;

  const ArticleScreen({
    super.key,
    required this.article,
    required this.isBookmarked,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleViewModel = context.read<ArticleViewModel>();
      articleViewModel.setBookmarkStatus(widget.isBookmarked);
      articleViewModel.fetchRelatedArticles(widget.article.id, widget.article.topic);
    });
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Consumer2<ArticleViewModel, BookmarkViewModel>(
        builder: (context, articleViewModel, bookmarkViewModel, _) {
          final isCurrentlyBookmarked = bookmarkViewModel.isBookmarked(widget.article.id);

          return CustomScrollView(
            slivers: [
              // 1. Sleek Sliver AppBar with Hero Image
              SliverAppBar(
                expandedHeight: widget.article.imageUrl != null ? 280 : 0,
                pinned: true,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F222A).withAlpha(200) : Colors.white.withAlpha(200),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F222A).withAlpha(200) : Colors.white.withAlpha(200),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isCurrentlyBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isCurrentlyBookmarked ? const Color(0xFF1877F2) : null,
                        size: 18,
                      ),
                    ),
                    onPressed: () => bookmarkViewModel.toggleBookmark(widget.article),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: widget.article.imageUrl != null
                    ? FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: widget.article.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: isDark ? const Color(0xFF1F222A) : const Color(0xFFEEF0F4),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: isDark ? const Color(0xFF1F222A) : const Color(0xFFEEF0F4),
                                child: const Icon(Icons.newspaper_rounded, color: Colors.grey, size: 40),
                              ),
                            ),
                            // Gradient overlay for smooth contrast
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withAlpha(120),
                                    Colors.transparent,
                                    isDark ? const Color(0xFF18191A) : Colors.white.withAlpha(180),
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),

              // 2. Article Body Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F2).withAlpha(30),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.article.topic.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1877F2),
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Article Title
                      Text(
                        widget.article.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Publisher details & Publish Date
                      Row(
                        children: [
                          PublisherBadge(sourceName: widget.article.sourceName, size: 36),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article.sourceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                timeago.format(widget.article.publishedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // External link button
                          IconButton(
                            icon: const Icon(Icons.open_in_new_rounded, size: 20),
                            onPressed: _launchUrl,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Divider(color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9)),
                      const SizedBox(height: 16),

                      // Article Content
                      Text(
                        widget.article.content.isNotEmpty
                            ? widget.article.content
                            : widget.article.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 16,
                          height: 1.7,
                          color: isDark ? const Color(0xFFD6D9E0) : const Color(0xFF2C323F),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Read Full Story CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _launchUrl,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.public_rounded, size: 20),
                          label: const Text(
                            'Read Full Story on Website',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Related News Section
                      Text(
                        'Related News',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // Related Articles List
              if (articleViewModel.state == ArticleState.loading &&
                  articleViewModel.relatedArticles.isEmpty)
                const SliverToBoxAdapter(child: ShimmerList(itemCount: 2))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final rel = articleViewModel.relatedArticles[index];
                      final isRelBookmarked = bookmarkViewModel.isBookmarked(rel.id);

                      return ArticleCard(
                        article: rel,
                        isBookmarked: isRelBookmarked,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ArticleScreen(
                                article: rel,
                                isBookmarked: isRelBookmarked,
                              ),
                            ),
                          );
                        },
                        onBookMarkTap: () => bookmarkViewModel.toggleBookmark(rel),
                      );
                    },
                    childCount: articleViewModel.relatedArticles.length,
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }
}
