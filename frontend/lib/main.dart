import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/home_page.dart';
import 'screens/character_selection_page.dart';
import 'screens/login_signup_page.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Children\'s Story Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Define the routes
      initialRoute: '/login', // This is the default page
      routes: {
        '/login': (context) => LoginPage(),        // login page
        '/home': (context) => HomePage(),          // home page
        '/profile': (context) => ProfilePage(), // profile page
        '/select-characters': (context) => const CharacterSelectionPage(),
        // '/login': (context) => const LoginPage(), // login/signup page
      },
    );
  }
}

