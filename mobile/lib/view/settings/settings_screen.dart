import 'package:flutter/material.dart';
import 'package:newztable/view/onboarding/onboardingScreen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_){
      context.read<SettingsViewModel>().loadSettings();
    });
  }

  Future<void> _onEditTopics() async {
    final topicViewModel = context.read<TopicViewModel>();
    final feedViewModel = context.read<FeedViewModel>();

    await topicViewModel.fetchAvailableTopics();

    if(!mounted) return;

    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => _EditTopicsSheet()));

    if(saved == true) {
      feedViewModel.fetchFeed(refresh: true);
    }
  }

  Future<void> _onClearData() async {
    final confirmed = await showDialog<bool>(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text('Clear local data?'),
        content: Text(
          "This will reset the app to it's initial state."
          'Your bookmarks and topic preferences will be lost.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: Text('Cancel')
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), 
            child: Text('Clear')
          )
        ],
      ),
    );

    if(confirmed == true && mounted){
      await context.read<SettingsViewModel>().clearLocalData();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Onboardingscreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          return ListView(
            children: [
              _SectionHeader(title: 'Preferences'),
              SwitchListTile(
                title: Text('Dark Mode'),
                subtitle: Text('Switch to dark theme'),
                secondary: Icon(viewModel.darkMode ? Icons.dark_mode_rounded: Icons.light_mode_rounded, color: colorScheme.primary),
                value: viewModel.darkMode, 
                onChanged: (_) => viewModel.toggleDarkMode()
              ),
              SwitchListTile(
                title: Text('Push Notification'),
                subtitle: Text('Get notified about breaking news'),
                secondary: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                value: viewModel.pushEnabled, 
                onChanged: (_) => viewModel.togglePushNotification()
              ),
              Divider(),
              _SectionHeader(title: 'Content'),
              ListTile(
                leading: Icon(Icons.topic_outlined, color: colorScheme.primary),
                title: Text('Edit Topics'),
                subtitle: Text('Change your personalized topics'),
                trailing: Icon(Icons.chevron_right_rounded),
                onTap: _onEditTopics,
              ),
              Divider(),
              _SectionHeader(title: 'About'),
              ListTile(
                leading: Icon(Icons.fingerprint_rounded, color: colorScheme.primary),
                title: Text('Device ID'),
                subtitle: Text(
                  viewModel.deviceId.isEmpty ? 'Loading...' : viewModel.deviceId,
                  style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                ),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              Divider(),
              _SectionHeader(title: 'Data'),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                ),
                title: Text(
                  'Clear Local Data',
                  style: TextStyle(color: colorScheme.error),
                ),
                subtitle: Text('Reset app to initial state'),
                onTap: _onClearData,
              )
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2
        )
      ),
    );
  }
}

class _EditTopicsSheet extends StatelessWidget {
  const _EditTopicsSheet ();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Topics'),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context, false), 
        ),
      ),
      body: Consumer<TopicViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: viewModel.availableTopics.map((topic){
                      final isSelected = viewModel.isSelected(topic);
                      return GestureDetector(
                        onTap: () => viewModel.toggleTopic(topic),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected? colorScheme.primary : colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isSelected? colorScheme.primary: colorScheme.outlineVariant, width: 1.5)
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if(isSelected) ...[
                                Icon(Icons.check_rounded, size: 16, color: colorScheme.onPrimary,),
                                SizedBox(width: 6)
                              ],
                              Text(
                                topic.label,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isSelected? colorScheme.onPrimary: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList()
                  ),
                )
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: viewModel.hasEnoughTopics && viewModel.state != TopicState.loading? () async {
                      final success = await viewModel.updateTopics();
                      if(success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    } : null,
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ), 
                    child: viewModel.state == TopicState.loading ?
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ):
                      Text(
                        'Save Topics',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      )
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}