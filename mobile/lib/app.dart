import 'package:flutter/material.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/constants/app_theme.dart';
import 'package:newztable/view/app_start_screen.dart';
import 'package:newztable/viewmodel/article_view_model.dart';
import 'package:newztable/viewmodel/bookmark_view_model.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:newztable/viewmodel/search_view_model.dart';
import 'package:newztable/viewmodel/settings_view_model.dart';
import 'package:newztable/viewmodel/topic_viewmodel.dart';
import 'package:provider/provider.dart';

class NewzTableApp extends StatelessWidget {
  const NewzTableApp ({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TopicViewModel()),
        ChangeNotifierProvider(create: (_) => FeedViewModel()),
        ChangeNotifierProvider(create: (_) => ArticleViewModel()),
        ChangeNotifierProvider(create: (_) => BookmarkViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel())
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: AppStartScreen(),
          );
        },
      ),
    );
  }
}