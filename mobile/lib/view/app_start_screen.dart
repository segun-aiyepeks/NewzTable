import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newztable/core/constants/app_constants.dart';
import 'package:newztable/view/home/home_screen.dart';
import 'package:newztable/view/onboarding/onboardingScreen.dart';
import 'package:newztable/viewmodel/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStartScreen extends StatefulWidget {
  const AppStartScreen({super.key});

  @override
  State<AppStartScreen> createState() => _AppStartScreenState();
}

class _AppStartScreenState extends State<AppStartScreen> {
  bool _isLoading = true;
  bool _isOnboarded = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
    context.read<SettingsViewModel>().loadSettings();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final topics = prefs.getStringList(AppConstants.topicsKey);
    setState(() {
      _isOnboarded = topics != null && topics.isNotEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    return _isOnboarded ? const HomeScreen() : const Onboardingscreen();
  }
}