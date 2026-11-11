import 'package:flutter/material.dart';
import 'package:newztable/view/article/article_screen.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/empty_view.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/search_view_model.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _trendingSearches = const [
    'Black Sea',
    'AI chips',
    'Champions League',
    'Renewable energy',
    'NASA spaceflight',
    'Ukraine conflict',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      context.read<SearchViewModel>().loadMore();
    }
  }

  void _onSearchChanged(String query) {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (query == _searchController.text && mounted) {
        context.read<SearchViewModel>().search(query);
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchViewModel>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
                width: 0.8,
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              autofocus: true,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF1A1D20),
              ),
              decoration: InputDecoration(
                hintText: 'Search articles, topics...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.state == SearchState.idle) {
            return _buildSearchSuggestions(isDark);
          }

          if (viewModel.state == SearchState.loading && viewModel.results.isEmpty) {
            return const ShimmerList(itemCount: 5);
          }

          if (viewModel.state == SearchState.empty) {
            return const EmptyView(
              icon: Icons.search_off_rounded,
              title: 'No articles found',
              message: 'Try checking your spelling or searching for a different keyword.',
            );
          }

          if (viewModel.state == SearchState.error) {
            return ErrorView(
              icon: Icons.search_off_rounded,
              message: viewModel.errorMessage,
              onRetry: () => viewModel.search(_searchController.text),
            );
          }

          return Consumer<BookmarkViewModel>(
            builder: (context, bookmarkViewModel, _) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: viewModel.results.length,
                itemBuilder: (context, index) {
                  final article = viewModel.results[index];
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
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchSuggestions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Searches',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFC5C9D3) : const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trendingSearches.map((term) {
              return ActionChip(
                label: Text(term),
                backgroundColor: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
                  ),
                ),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white : const Color(0xFF1A1D20),
                ),
                onPressed: () {
                  _searchController.text = term;
                  context.read<SearchViewModel>().search(term);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
