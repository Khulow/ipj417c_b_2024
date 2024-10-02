import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/miscellenous/images.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo with Notification Badge
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.asset(
                  mWelcomeImage, // Placeholder for your logo
                  height: 150,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Welcome to RoomM8',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Subtitle
            const SizedBox(height: 10),
            Text(
              'Find your perfect student accommodation',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 40),

            // Sign-up Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366), // Dark Blue color
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Handle Sign-up action
              },
              child: const Text(
                'Sign up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Login Button with Outline
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                side: const BorderSide(
                    color: Color(0xFF003366)), // Dark Blue border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Handle Login action
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF003366), // Dark Blue color
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // OR with Google Sign-in
            Text('or continue with',
                style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Handle Google login
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      mGoogleLogo, // Placeholder for Google icon
                      height: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Google',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Terms and Privacy Policy
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'By signing up, you agree to our ',
                style: TextStyle(color: Colors.grey[600]),
                children: const [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    // You can link to the terms of service
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                    // You can link to the privacy policy
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
