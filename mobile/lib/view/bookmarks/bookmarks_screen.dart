import 'package:flutter/material.dart';
import 'package:newztable/view/article/article_screen.dart';
import 'package:newztable/view/widgets/article_card.dart';
import 'package:newztable/view/widgets/empty_view.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/view/widgets/shimmer_card.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Stories',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<BookmarkViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.state == BookmarkState.loading && viewModel.bookmarks.isEmpty) {
            return const ShimmerList(itemCount: 4);
          }

          if (viewModel.state == BookmarkState.error && viewModel.bookmarks.isEmpty) {
            return ErrorView(
              message: viewModel.errorMessage,
              onRetry: viewModel.fetchBookmarks,
            );
          }

          if (viewModel.isEmpty) {
            return const EmptyView(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved stories yet',
              message: 'Tap the bookmark icon on any article to save it for reading later.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchBookmarks(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = viewModel.bookmarks[index];
                return Dismissible(
                  key: Key(bookmark.bookmarkId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
                  ),
                  onDismissed: (_) {
                    viewModel.removeBookmarks(bookmark.article.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Article removed from saved.'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () => viewModel.addBookmark(bookmark.article),
                        ),
                      ),
                    );
                  },
                  child: ArticleCard(
                    article: bookmark.article,
                    isBookmarked: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleScreen(
                            article: bookmark.article,
                            isBookmarked: true,
                          ),
                        ),
                      );
                    },
                    onBookMarkTap: () => viewModel.removeBookmarks(bookmark.article.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
