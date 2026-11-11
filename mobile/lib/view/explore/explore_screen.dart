import 'package:flutter/material.dart';
import 'package:newztable/view/article/article_screen.dart';
import 'package:newztable/view/search/search_screen.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final popularPublishers = [
      {'name': 'BBC News', 'followers': '1.2M'},
      {'name': 'CNN', 'followers': '980K'},
      {'name': 'The Guardian', 'followers': '850K'},
      {'name': 'USA Today', 'followers': '620K'},
      {'name': 'The Verge', 'followers': '540K'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FeedViewModel>(
        builder: (context, feedViewModel, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // 1. Search Bar shortcut
              Padding(
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
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Search news, topics, publishers...',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF7A808C) : const Color(0xFF9CA3AF),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 2. Popular Topics Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trending Topics',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: feedViewModel.categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = feedViewModel.categories[index];
                    final isSelected = feedViewModel.selectedCategory.toLowerCase() == cat.toLowerCase();

                    return ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) => feedViewModel.selectCategory(cat),
                      selectedColor: const Color(0xFF1877F2),
                      backgroundColor: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? const Color(0xFFC5C9D3) : const Color(0xFF4B5563)),
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF1877F2)
                              : (isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 3. Top Publishers Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Top Publishers',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: popularPublishers.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final pub = popularPublishers[index];
                    return Container(
                      width: 110,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1F222A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PublisherBadge(sourceName: pub['name']!, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            pub['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pub['followers']!,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // 4. Curated Stories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recommended For You',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Consumer<BookmarkViewModel>(
                builder: (context, bookmarkViewModel, _) {
                  final items = feedViewModel.trendingArticles;
                  return Column(
                    children: items.map((article) {
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
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
