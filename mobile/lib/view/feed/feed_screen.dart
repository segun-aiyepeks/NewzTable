import 'package:flutter/material.dart';
import 'package:newztable/model/feed_item_model.dart';
import 'package:newztable/view/widgets/ad_card.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<FeedViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NewzTable',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w800
          ),
        ),
        actions: [
          Consumer<FeedViewModel>(
            builder: (context, feedViewModel, _) {
              return IconButton(
                icon: feedViewModel.isRefreshing? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                ): const Icon(Icons.refresh_rounded),
                onPressed: () => feedViewModel.refresh(), 
              );
            },
          )
        ],
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, feedViewModel, _) {
          if(feedViewModel.state == FeedState.loading && feedViewModel.feedItems.isEmpty) {
            return const ShimmerList(itemCount: 6);
          }
          if(feedViewModel.state == FeedState.error && feedViewModel.feedItems.isEmpty) {
            return ErrorView(
              message: feedViewModel.errorMessage, 
              onRetry: () => feedViewModel.fetchFeed()
            );
          }

          return RefreshIndicator(
            onRefresh: () => feedViewModel.refresh(), 
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: feedViewModel.feedItems.length + 1,
              itemBuilder: (context, index) {
                if(index == feedViewModel.feedItems.length) {
                  return _buildBottomLoader(feedViewModel);
                }

                final item = feedViewModel.feedItems[index];
                return _buildFeedItem(context, item);
              },
            )
          );
        }
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, FeedItemModel item) {
  if(item.isAd) {
    return AdCard(slotId: item.slotId!);
  }
  final article = item.article!;
  
  return Consumer<BookmarkViewModel>(
    builder: (context, bookmarkViewModel, _) {
      return ArticleCard(
        article: article,
        isBookmarked: bookmarkViewModel.isBookmarked(article.id), 
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => ArticleScreen(
              article: article,
              isBookmarked: bookmarkViewModel.isBookmarked(article.id)
            )
          ));
        }
      );
    },
  );
}

Widget _buildBottomLoader(FeedViewModel feedViewModel) {
  if (feedViewModel.state == FeedState.loadingMore) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator(),),
    );
  }

  if (!feedViewModel.hasMore) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Text(
          "You're all caught up!",
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
  return SizedBox.shrink();
  }
}