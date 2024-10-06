import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/miscellenous/images.dart';

class OnboardingScreen1 extends StatelessWidget {
  final PageController pageController;

  const OnboardingScreen1({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        backgroundColor: const Color(0xFF003366), // Primary Blue color
        body: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Section
              const Padding(
                padding: EdgeInsets.only(top: 30.0, left: 8.0),
                child: Text(
                  'Find your \nperfect home,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Discover a wide range of student accommodation near your campus',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Button Section
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFFCC00), // Yellow Accent color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  onPressed: () {
                    // Action to go to the next page
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.black), // Black text
                  ),
                ),
              ),

              const Spacer(),

              // Image Section
              Image.asset(
                  mOnboardingImage), // Placeholder for the building image
            ],
          ),
        ),
      ),
    );
  }
}
