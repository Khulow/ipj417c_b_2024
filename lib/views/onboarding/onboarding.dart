import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/views/onboarding/screen1.dart';
import 'package:ipj417c_b_2024/views/onboarding/screen2.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreensState createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          // First Screen: "Find your perfect home"
          OnboardingScreen1(pageController: _pageController),

          // Second Screen: "Easy Search"
          OnboardingScreen2(pageController: _pageController),
        ],
      ),
    );
  }
}
