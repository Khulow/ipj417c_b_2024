import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ipj417c_b_2024/firebase_options.dart';
import 'package:ipj417c_b_2024/providers/navigation_provider.dart';
import 'package:ipj417c_b_2024/viewmodels/listing_view_model.dart';
import 'package:ipj417c_b_2024/viewmodels/user_view_model.dart';
import 'package:ipj417c_b_2024/views/admin_listing_view.dart';
import 'package:ipj417c_b_2024/views/auth/login_screen.dart';
import 'package:ipj417c_b_2024/views/home/home_page.dart';
import 'package:ipj417c_b_2024/views/onboarding/onboarding.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add a ChangeNotifierProvider for UserViewModel
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        ChangeNotifierProvider(create: (context) => ListingsViewModel()),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
        //ChangeNotifierProvider(create: (context) => AuthViewModel()),
      ],
      builder: (context, child) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: //AdminListingsView()
                //HomePage()
                LoginScreen()
            //OnboardingScreens(),
            //EditProfileScreen()
            //
            );
      },
    );
  }
}
