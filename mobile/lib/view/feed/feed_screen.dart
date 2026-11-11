import 'package:flutter/material.dart';
import 'package:newztable/model/feed_item_model.dart';
import 'package:newztable/view/article/article_screen.dart';
import 'package:newztable/view/notification/notification_screen.dart';
import 'package:newztable/view/search/search_screen.dart';
import 'package:newztable/view/trending/trending_screen.dart';
import 'package:newztable/view/widgets/ad_card.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/view/widgets/trending_card.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: _buildCustomAppBar(context, theme, isDark),
      body: Consumer<FeedViewModel>(
        builder: (context, feedViewModel, _) {
          if (feedViewModel.state == FeedState.loading && feedViewModel.feedItems.isEmpty) {
            return const ShimmerList(itemCount: 6);
          }

          if (feedViewModel.state == FeedState.error && feedViewModel.feedItems.isEmpty) {
            return ErrorView(
              message: feedViewModel.errorMessage,
              onRetry: () => feedViewModel.fetchFeed(),
            );
          }

          final trendingList = feedViewModel.trendingArticles;
          final topTrending = trendingList.isNotEmpty ? trendingList.first : null;

          return RefreshIndicator(
            onRefresh: () => feedViewModel.refresh(),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // 1. Search Bar with Filter Icon
                _buildSearchBar(context, isDark),

                const SizedBox(height: 12),

                // 2. Trending Section
                if (topTrending != null) ...[
                  _buildSectionHeader(
                    title: 'Trending',
                    onSeeAllTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrendingScreen()),
                      );
                    },
                    theme: theme,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Consumer<BookmarkViewModel>(
                      builder: (context, bookmarkViewModel, _) {
                        final isBookmarked = bookmarkViewModel.isBookmarked(topTrending.id);
                        return TrendingCard(
                          article: topTrending,
                          isBookmarked: isBookmarked,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArticleScreen(
                                  article: topTrending,
                                  isBookmarked: isBookmarked,
                                ),
                              ),
                            );
                          },
                          onBookmarkTap: () => bookmarkViewModel.toggleBookmark(topTrending),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 3. Latest Section Header
                _buildSectionHeader(
                  title: 'Latest',
                  onSeeAllTap: () {
                    // Navigate to Trending / Full Feed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrendingScreen()),
                    );
                  },
                  theme: theme,
                ),

                // 4. Category Tabs (All, Sports, Politics, Business, Health, Travel, Science)
                _buildCategoryTabs(feedViewModel, isDark),

                const SizedBox(height: 8),

                // 5. Latest Articles List
                ...feedViewModel.latestItems.map((item) {
                  return _buildFeedItem(context, item);
                }),

                // 6. Bottom loader
                _buildBottomLoader(feedViewModel),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(BuildContext context, ThemeData theme, bool isDark) {
    return AppBar(
      titleSpacing: 16,
      title: Row(
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF18191A),
              ),
              children: const [
                TextSpan(text: 'Newz'),
                TextSpan(
                  text: 'Table',
                  style: TextStyle(color: Color(0xFF1877F2)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2).withAlpha(35),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.article_rounded,
              size: 16,
              color: Color(0xFF1877F2),
            ),
          ),
        ],
      ),
      actions: [
        // Notification Bell Icon with unread badge
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
                    width: 0.8,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.notifications_outlined, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationScreen()),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1877F2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search',
                  style: TextStyle(
                    color: isDark ? const Color(0xFF7A808C) : const Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.tune_rounded,
                  color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAllTap,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          GestureDetector(
            onTap: onSeeAllTap,
            child: const Text(
              'See all',
              style: TextStyle(
                color: Color(0xFF1877F2),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(FeedViewModel feedViewModel, bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: feedViewModel.categories.length,
        itemBuilder: (context, index) {
          final cat = feedViewModel.categories[index];
          final isSelected = feedViewModel.selectedCategory.toLowerCase() == cat.toLowerCase();

          return GestureDetector(
            onTap: () => feedViewModel.selectCategory(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF1877F2)
                          : (isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Active underline indicator matching inspiration
                  Container(
                    height: 2.5,
                    width: isSelected ? 24 : 0,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedItem(BuildContext context, FeedItemModel item) {
    if (item.isAd) {
      return AdCard(slotId: item.slotId!);
    }
    final article = item.article!;

    return Consumer<BookmarkViewModel>(
      builder: (context, bookmarkViewModel, _) {
        final isBookmarked = bookmarkViewModel.isBookmarked(article.id);
        return ArticleCard(
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
          onBookMarkTap: () => bookmarkViewModel.toggleBookmark(article),
        );
      },
    );
  }

  Widget _buildBottomLoader(FeedViewModel feedViewModel) {
    if (feedViewModel.state == FeedState.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!feedViewModel.hasMore) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            "You're all caught up!",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
