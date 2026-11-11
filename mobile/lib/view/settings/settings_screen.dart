import 'package:flutter/material.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/view/onboarding/onboardingScreen.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';
import 'package:newztable/viewmodel/feed_view_model.dart';
import 'package:newztable/viewmodel/settings_view_model.dart';
import 'package:newztable/viewmodel/topic_viewmodel.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsViewModel>().loadSettings();
    });
  }

  Future<void> _onEditTopics() async {
    final topicViewModel = context.read<TopicViewModel>();
    final feedViewModel = context.read<FeedViewModel>();

    await topicViewModel.fetchAvailableTopics();

    if (!mounted) return;

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const _EditTopicsSheet()),
    );

    if (saved == true) {
      feedViewModel.fetchFeed(refresh: true);
    }
  }

  void _showApiProviderSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_rounded, color: Color(0xFF1877F2)),
                      const SizedBox(width: 8),
                      Text(
                        'Select Active News API',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildApiOption(
                    title: 'Free Public Feeds (BBC, CNN, TechCrunch)',
                    subtitle: '100% Free & Live. No API key required.',
                    value: NewsApiProvider.freeRssFeeds,
                    current: AppConstants.activeProvider,
                    onTap: () {
                      setState(() {
                        AppConstants.activeProvider = NewsApiProvider.freeRssFeeds;
                      });
                      context.read<FeedViewModel>().fetchFeed(refresh: true);
                      Navigator.pop(context);
                    },
                  ),
                  _buildApiOption(
                    title: 'The Guardian Open Platform',
                    subtitle: '5,000 calls/day. High quality journalism.',
                    value: NewsApiProvider.theGuardian,
                    current: AppConstants.activeProvider,
                    onTap: () {
                      setState(() {
                        AppConstants.activeProvider = NewsApiProvider.theGuardian;
                      });
                      context.read<FeedViewModel>().fetchFeed(refresh: true);
                      Navigator.pop(context);
                    },
                  ),
                  _buildApiOption(
                    title: 'NewsAPI.org',
                    subtitle: 'Multi-source news aggregator (requires API key).',
                    value: NewsApiProvider.newsApiOrg,
                    current: AppConstants.activeProvider,
                    onTap: () {
                      setState(() {
                        AppConstants.activeProvider = NewsApiProvider.newsApiOrg;
                      });
                      context.read<FeedViewModel>().fetchFeed(refresh: true);
                      Navigator.pop(context);
                    },
                  ),
                  _buildApiOption(
                    title: 'Local Express Server',
                    subtitle: 'http://192.168.1.146:5000 custom backend.',
                    value: NewsApiProvider.localBackend,
                    current: AppConstants.activeProvider,
                    onTap: () {
                      setState(() {
                        AppConstants.activeProvider = NewsApiProvider.localBackend;
                      });
                      context.read<FeedViewModel>().fetchFeed(refresh: true);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildApiOption({
    required String title,
    required String subtitle,
    required NewsApiProvider value,
    required NewsApiProvider current,
    required VoidCallback onTap,
  }) {
    final isSelected = value == current;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1877F2).withAlpha(20) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF1877F2) : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF1877F2)) : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> _onClearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local data?'),
        content: const Text(
          'This will reset the app to its initial state. '
          'Your bookmarks and topic preferences will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<SettingsViewModel>().clearLocalData();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Onboardingscreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // 1. User Profile Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1F222A) : const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFF1877F2),
                      child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'News Reader',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Personalized Edition',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1877F2).withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          color: Color(0xFF1877F2),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Preferences
              _SectionHeader(title: 'Display & Experience'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Switch between dark & light themes', style: TextStyle(fontSize: 12)),
                secondary: Icon(
                  viewModel.darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: colorScheme.primary,
                ),
                value: viewModel.darkMode,
                onChanged: (_) => viewModel.toggleDarkMode(),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Get notified about breaking news', style: TextStyle(fontSize: 12)),
                secondary: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                value: viewModel.pushEnabled,
                onChanged: (_) => viewModel.togglePushNotification(),
              ),

              const SizedBox(height: 12),
              Divider(color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9)),
              const SizedBox(height: 12),

              // 3. News Source & Content
              _SectionHeader(title: 'News Feed & Connectivity'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.hub_rounded, color: colorScheme.primary),
                title: const Text('Active News API Source', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  _getProviderName(AppConstants.activeProvider),
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1877F2)),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _showApiProviderSelector,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.category_outlined, color: colorScheme.primary),
                title: const Text('Customize Topics', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Personalize the topics in your feed', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _onEditTopics,
              ),

              const SizedBox(height: 12),
              Divider(color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9)),
              const SizedBox(height: 12),

              // 4. Data & App Info
              _SectionHeader(title: 'Data & App Info'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_sweep_outlined, color: colorScheme.error),
                title: Text(
                  'Reset Local App Data',
                  style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Clear bookmarks and local topic preferences', style: TextStyle(fontSize: 12)),
                onTap: _onClearData,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info_outline_rounded, color: colorScheme.outline),
                title: const Text('NewzTable Version', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('${AppConstants.appName} v${AppConstants.appVersion}'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getProviderName(NewsApiProvider provider) {
    switch (provider) {
      case NewsApiProvider.freeRssFeeds:
        return 'Free Public Feeds (BBC, CNN, TechCrunch)';
      case NewsApiProvider.theGuardian:
        return 'The Guardian Open Platform';
      case NewsApiProvider.newsApiOrg:
        return 'NewsAPI.org';
      case NewsApiProvider.localBackend:
        return 'Local Express Backend';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF1877F2),
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _EditTopicsSheet extends StatefulWidget {
  const _EditTopicsSheet();

  @override
  State<_EditTopicsSheet> createState() => _EditTopicsSheetState();
}

class _EditTopicsSheetState extends State<_EditTopicsSheet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Topics'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Consumer<TopicViewModel>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'World',
                'Sports',
                'Politics',
                'Business',
                'Health',
                'Travel',
                'Science',
                'Technology',
              ].map((topic) {
                return Chip(
                  label: Text(topic),
                  backgroundColor: const Color(0xFF1877F2).withAlpha(25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFF1877F2)),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
