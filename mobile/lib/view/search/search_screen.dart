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
    if(_scrollController.position.pixels >= _scrollController.position.maxScrollExtent -300) {
      context.read<SearchViewModel>().loadMore();
    }
  }

  void _onSearchChanged(String query) {
    Future.delayed(Duration(milliseconds: 500), (){
      if(query == _searchController.text) {
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Search articles...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme.outline)
          ),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          Consumer<SearchViewModel>(
            builder: (context, viewModel, _) {
              if(_searchController.text.isEmpty)return SizedBox.shrink();
              return IconButton(
                onPressed: _clearSearch, 
                icon: Icon(Icons.close_rounded)
              );
            },
          )
        ],
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, _) {
          if(viewModel.state == SearchState.idle) {
            return EmptyView(
              icon: Icons.search_rounded,
              title: 'Search for any article', 
              message: 'Find articles on bitcoins, elections, AI and more...'
            );
          }

          if(viewModel.state == SearchState.loading && viewModel.results.isEmpty){
            return const ShimmerList(itemCount: 5);
          }

          if(viewModel.state == SearchState.error) {
            return ErrorView(
              icon: Icons.search_off_rounded,
              message: viewModel.errorMessage, 
              onRetry: () => viewModel.search(viewModel.lastQuery)
            );
          }

          if(viewModel.state == SearchState.empty) {
            return EmptyView(
              icon: Icons.search_off_rounded,
              title: 'No results found', 
              message: 'No articles matched "${viewModel.lastQuery}". Try a different keywords.');
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: viewModel.results.length + 1,
            itemBuilder: (context, index) {
              if(index == viewModel.results.length) {
                if(viewModel.state == SearchState.loading){
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'End of results',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }

              final article = viewModel.results[index];
              return Consumer<BookmarkViewModel>(
                builder: (context, bookmarkViewModel, _) {
                  return ArticleCard(
                    article: article,
                    isBookmarked: bookmarkViewModel.isBookmarked(article.id), 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleScreen(article: article, isBookmarked: bookmarkViewModel.isBookmarked(article.id))));
                    },
                    onBookMarkTap: () => bookmarkViewModel.removeBookmarks(article.id),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}