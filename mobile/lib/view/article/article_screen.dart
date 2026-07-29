import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:newztable/model/article_model.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/viewmodel/article_view_model.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

class ArticleScreen extends StatefulWidget {
  final ArticleModel article;
  final bool isBookmarked;

  const ArticleScreen({super.key, required this.article, required this.isBookmarked});

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
      articleViewModel.fetchArticle(widget.article.id);
    });
  }

  Future<void> _launchUrl() async {
    final uri = Uri.parse(widget.article.url);
    if(await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleBookmark() async {
    final articleViewModel = context.read<ArticleViewModel>();
    final bookmarkViewModel = context.read<BookmarkViewModel>();

    await articleViewModel.toggleBookmark(widget.article.id);

    if(articleViewModel.isBookmarked) {
      bookmarkViewModel.fetchBookmarks();
    } else {
      bookmarkViewModel.removeBookmarks(widget.article.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Consumer<ArticleViewModel>(
        builder: (context, articleViewModel, _) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: widget.article.imageUrl != null? 250: 0,
                pinned: true,
                actions: [
                  IconButton(
                    icon: Icon(
                      articleViewModel.isBookmarked? Icons.bookmark_rounded: Icons.bookmark_border_rounded,
                      color: articleViewModel.isBookmarked? colorScheme.primary : null,
                    ),
                    onPressed: _toggleBookmark, 
                  )
                ],
                flexibleSpace: widget.article.imageUrl != null?
                  FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: widget.article.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ): null
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: Text(
                              widget.article.topic.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            widget.article.sourceName,
                            style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            timeago.format(widget.article.publishedAt),
                            style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                          )
                        ],
                      ),
                      SizedBox(height: 16),
                      Text(
                        widget.article.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3
                        )
                      ),
                      SizedBox(height: 12),
                      if (widget.article.description.isNotEmpty) ...[
                        Text(
                          widget.article.description,
                          style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.6),
                        ),
                        SizedBox(height: 16)
                      ],
                      if(widget.article.content.isNotEmpty) ...[
                        Text(
                          widget.article.content,
                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.7),
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis
                        ),
                        SizedBox(height: 24)
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _launchUrl,
                          icon: Icon(Icons.open_in_new_rounded), 
                          label: Text('Continue reading on ${widget.article.sourceName}'),
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      if(articleViewModel.state == ArticleState.loading)
                        const ShimmerList(itemCount: 3),
                      if(articleViewModel.state == ArticleState.error)
                        ErrorView(
                          message: articleViewModel.errorMessage, 
                          onRetry: () => articleViewModel.fetchArticle(widget.article.id)
                        ),
                      if(articleViewModel.state == ArticleState.success && articleViewModel.relatedArticles.isNotEmpty) ...[
                        Text(
                          'More from ${widget.article.topic}',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 12),
                        ...articleViewModel.relatedArticles
                          .map((related) => ArticleCard(
                            article: related, 
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ArticleScreen(article: related, isBookmarked: false)));
                            }
                          ))
                      ]
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}