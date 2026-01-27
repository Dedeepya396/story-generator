import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ====== Body ======
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Hero Section with Navbar =====
            Container(
              height: 700,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    'assets/images/Homepage_img.png',
                    fit: BoxFit.cover,
                  ),
                  // Dark overlay
                  Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                  // Content (Navbar + Hero Text)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Column(
                      children: [
                        // ===== Navigation Buttons =====
                        Padding(
                          padding: const EdgeInsets.only(top: 20, bottom: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pushNamed(context, '/'),
                                child: Text(
                                  'Home',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 40),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/select-characters');
                                  },
                                  child: const Text(
                                    'Create Story',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              

                              SizedBox(width: 40),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/about'),
                                child: Text(
                                  'About',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 40),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/login'),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(width: 40),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/profile'),
                                child: Text(
                                  'Profile',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        // ===== Hero Text =====
                        Text(
                          'Welcome to TinyTales',
                          style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Generate and enjoy some light hearted tales for little ones!',
                          style:
                              TextStyle(fontSize: 20, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Top Stories Section =====
            Container(
              height: 700,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.asset(
                    'assets/images/HP-up.png',
                    fit: BoxFit.cover,
                  ),
                  // Dark overlay
                  Container(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  // Top Stories content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 80, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          'Our Top Stories',
                          style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        SizedBox(height: 50),
                        Wrap(
                          spacing: 40,
                          runSpacing: 40,
                          alignment: WrapAlignment.center,
                          children: [
                            FeatureCard(
                              icon: Icons.star,
                              title: 'Tortoise and the Hare',
                              description:
                                  'This is a classic tale about the importance of perseverance and humility.',
                            ),
                            FeatureCard(
                              icon: Icons.star,
                              title: 'Rabbit and Traffic signals',
                              description:
                                  'This is an informative story about traffic signals and their meaning.',
                            ),
                            FeatureCard(
                              icon: Icons.star,
                              title: 'The Lion and the Mouse',
                              description:
                                  'A heartwarming tale that shows even the smallest friends can make a big difference.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ===== Footer (optional) =====
            // Container(
            //   width: double.infinity,
            //   color: Colors.blueGrey[900],
            //   padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            //   child: Column(
            //     children: [
            //       Text(
            //         '© 2026 TinyTales. All rights reserved.',
            //         style: TextStyle(color: Colors.white),
            //       ),
            //       SizedBox(height: 10),
            //       Text(
            //         'Follow us on social media',
            //         style: TextStyle(color: Colors.white70),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

// ===== Feature Card Widget =====
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  FeatureCard(
      {required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 350,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 50, color: Colors.blue),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
