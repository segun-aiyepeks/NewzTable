import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/core/utils/device_id_util.dart';
import 'package:newztable/model/topic_model.dart';
import 'package:newztable/view/home/home_screen.dart';
import 'package:newztable/view/widgets/error_view.dart';
import 'package:newztable/viewmodel/topic_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Onboardingscreen extends StatefulWidget {
  const Onboardingscreen({super.key});

  @override
  State<Onboardingscreen> createState() => _OnboardingscreenState();
}

class _OnboardingscreenState extends State<Onboardingscreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TopicViewModel>().fetchAvailableTopics();
    });
  }

  Future<void> _onConfirm() async {
    final viewModel = context.read<TopicViewModel>();
    final deviceId = await DeviceIdUtil.getOrCreateDeviceId();
    final success = await viewModel.saveSelectedTopics(deviceId);

    if (success && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.topicsKey, viewModel.selectedTopics.map((t) => t.key).toList());

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer<TopicViewModel>(
          builder: (context, viewModel, _) {
            if(viewModel.state == TopicState.loading && viewModel.availableTopics.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            if(viewModel.state == TopicState.error && viewModel.availableTopics.isEmpty) {
              return ErrorView(message: viewModel.errorMessage, onRetry: () => viewModel.fetchAvailableTopics());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NewzTable',
                        style: theme.textTheme.headlineSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'What are you interested in?',
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pick at least 3 topics to personalize your feed.',
                        style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
                      )
                    ],
                  ),  
                ),
                SizedBox(height: 32.0),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: viewModel.availableTopics.map((topic) => _TopicChip(
                        topic: topic, 
                        isSelected: viewModel.isSelected(topic), 
                        onTap: () => viewModel.toggleTopic(topic)
                        )).toList()
                    ),
                    
                  )
                ),
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if(viewModel.state == TopicState.error)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            viewModel.errorMessage,
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: viewModel.hasEnoughTopics && viewModel.state != TopicState.loading ? _onConfirm : null,
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                            ), 
                            child: viewModel.state == TopicState.loading ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              viewModel.selectedTopics.isEmpty ? 
                              'Select at least 3 topics' :
                              '${viewModel.selectedTopics.length} selected - Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600
                              ),
                            )
                          ),
                        )
                    ],
                  ),
                  
                )
              ],
            );
          },
        )
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final TopicModel topic;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({required this.topic, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? colorScheme.primary: colorScheme.outlineVariant,
            width: 1.5
          )
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if(isSelected) ...[
              Icon(Icons.check_rounded, size: 16, color: colorScheme.onPrimary),
              SizedBox(width: 6)
            ],
            Text(
              topic.label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      ),
    );
  }
}