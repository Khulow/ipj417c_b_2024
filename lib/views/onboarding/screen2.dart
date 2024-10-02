import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/miscellenous/images.dart';
import 'package:ipj417c_b_2024/views/welcome/welcome_screen.dart';

class OnboardingScreen2 extends StatelessWidget {
  final PageController pageController;

  const OnboardingScreen2({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // White Background
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
                  'Easy Search',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Filter by price, location, and amenities to find your ideal accommodation',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Button Section
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFFCC00), // Yellow Accent color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  // Action to go to the next page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const WelcomeScreen(), // Navigate to a Home screen
                    ),
                  );
                },
                child: const Text(
                  'Get Started',
                  style: TextStyle(color: Colors.black), // Black text
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
