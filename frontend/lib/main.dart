import 'package:flutter/material.dart';
import 'screens/profile_page.dart';
import 'screens/home_page.dart';
import 'screens/character_selection_page.dart';
import 'screens/login_signup_page.dart';
import 'screens/my_stories.dart';
import 'screens/write_story_page.dart';


// void main() {
//   runApp(const MyApp());
// }


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Children\'s Story Generator',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       // Define the routes
//       initialRoute: '/login', // This is the default page
//       routes: {
//         '/login': (context) => LoginPage(),        // login page
//         '/home': (context) => HomePage(),          // home page
//         '/profile': (context) => ProfilePage(), // profile page
//         '/library': (context) => const CharacterSelectionPage(),
//         '/my-stories': (context) => const MyStoriesPage(), // my stories page (reuse profile for now)
//         // '/login': (context) => const LoginPage(), // login/signup page
//         '/story-input': (context) => const WriteStoryPage(selectedCharacters: [],), // story input page (reuse character selection for now)
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool loginStatus = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      isLoggedIn = loginStatus;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (isLoggedIn == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

return MaterialApp(
  home: isLoggedIn == true ? HomePage() : LoginPage(),
  routes: {
    '/home': (context) => HomePage(),
    '/profile': (context) => ProfilePage(),
    '/library': (context) => const CharacterSelectionPage(),
    '/my-stories': (context) => const MyStoriesPage(),
    '/story-input': (context) =>
        const WriteStoryPage(selectedCharacters: []),
  },
);  }
}