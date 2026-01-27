import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/home_page.dart';
import 'screens/character_selection_page.dart';


void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Define the routes
      initialRoute: '/', // This is the default page
      routes: {
        '/': (context) => HomePage(),        // home page
        '/profile': (context) => ProfilePage(), // profile page
        '/select-characters': (context) => const CharacterSelectionPage(),

      },
    );
  }
}

