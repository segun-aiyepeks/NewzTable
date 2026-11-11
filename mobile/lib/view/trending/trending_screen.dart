import 'package:flutter/material.dart';
import 'package:newztable/view/article/article_screen.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/view/widgets/trending_card.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:provider/provider.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trending',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trending stories updated regularly.')),
              );
            },
          ),
        ],
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, feedViewModel, _) {
          if (feedViewModel.state == FeedState.loading && feedViewModel.trendingArticles.isEmpty) {
            return const ShimmerList(itemCount: 4);
          }

          if (feedViewModel.state == FeedState.error && feedViewModel.trendingArticles.isEmpty) {
            return ErrorView(
              message: feedViewModel.errorMessage,
              onRetry: () => feedViewModel.fetchFeed(),
            );
          }

          final trending = feedViewModel.trendingArticles;

          if (trending.isEmpty) {
            return const Center(
              child: Text('No trending stories right now.'),
            );
          }

          return Consumer<BookmarkViewModel>(
            builder: (context, bookmarkViewModel, _) {
              return RefreshIndicator(
                onRefresh: () => feedViewModel.refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: trending.length,
                  itemBuilder: (context, index) {
                    final article = trending[index];
                    final isBookmarked = bookmarkViewModel.isBookmarked(article.id);

                    return TrendingCard(
                      article: article,
                      isBookmarked: isBookmarked,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArticleScreen(
                              article: article,
                              isBookmarked: isBookmarked,
                            ),
                          ),
                        );
                      },
                      onBookmarkTap: () => bookmarkViewModel.toggleBookmark(article),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
