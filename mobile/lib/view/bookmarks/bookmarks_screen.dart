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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Articles',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<BookmarkViewModel>(
        builder:  (context, viewModel, _) {
          if(viewModel.state == BookmarkState.loading){
            ShimmerList(itemCount: 4);
          }

          if(viewModel.state == BookmarkState.error) {
            return ErrorView(
              message: viewModel.errorMessage, 
              onRetry: viewModel.fetchBookmarks
            );
          }

          if(viewModel.isEmpty) {
            return EmptyView(
              icon: Icons.bookmark_border_rounded,
              title: 'No saved articles yet', 
              message: 'Tap the bookmark icon on any article to save it for later.'
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.fetchBookmarks(), 
            child: ListView.builder(
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: viewModel.bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = viewModel.bookmarks[index];
                return Dismissible(
                  key: Key(bookmark.bookmarkId),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12)
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete_outline_rounded, color: Colors.white,),
                  ),
                  onDismissed: (_) {
                    viewModel.removeBookmarks(bookmark.article.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Article removed from saved.'),
                        action: SnackBarAction(label: 'Undo', onPressed: () => viewModel.fetchBookmarks()),
                      )
                    );
                  }, 
                  child: ArticleCard(
                    article: bookmark.article,
                    isBookmarked: true, 
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleScreen(article: bookmark.article, isBookmarked: true,)));
                    },
                    onBookMarkTap: () => viewModel.removeBookmarks(bookmark.article.id),
                  )
                );
              },
            
            )
          );
        },
      ),
    );
  }
}