// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   bool isLoginMode = true; // true for login, false for signup
  
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     nameController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void handleSubmit() {
//     if (isLoginMode) {
//       // Handle login
//       String email = emailController.text;
//       String password = passwordController.text;
      
//       print('Login attempt:');
//       print('Email: $email');
//       print('Password: $password');
      
//       // Navigate to home page or wherever you want
//       Navigator.pushReplacementNamed(context, '/');
      
//     } else {
//       // Handle signup
//       String name = nameController.text;
//       String email = emailController.text;
//       String password = passwordController.text;
//       String confirmPassword = confirmPasswordController.text;
      
//       print('Signup attempt:');
//       print('Name: $name');
//       print('Email: $email');
//       print('Password: $password');
//       print('Confirm Password: $confirmPassword');
      
//       // Navigate to home page or wherever you want
//       Navigator.pushReplacementNamed(context, '/');
//     }
//   }

//   void toggleMode() {
//     setState(() {
//       isLoginMode = !isLoginMode;
//       // Clear all fields when switching modes
//       emailController.clear();
//       passwordController.clear();
//       nameController.clear();
//       confirmPasswordController.clear();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF87CEEB), // Sky blue
//               Color(0xFF98FB98), // Pale green
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 400),
//                 child: Card(
//                   elevation: 8,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(30),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // Title
//                         Text(
//                           isLoginMode ? 'Welcome Back!' : 'Create Account',
//                           style: const TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           isLoginMode 
//                             ? 'Sign in to continue your story journey' 
//                             : 'Join us to create amazing stories',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 40),

//                         // Name field (only for signup)
//                         if (!isLoginMode) ...[
//                           TextField(
//                             controller: nameController,
//                             decoration: InputDecoration(
//                               labelText: 'Full Name',
//                               prefixIcon: const Icon(Icons.person, color: Color(0xFF2E7D32)),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Color(0xFF2E7D32)),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                         ],

//                         // Email field
//                         TextField(
//                           controller: emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             prefixIcon: const Icon(Icons.email, color: Color(0xFF2E7D32)),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF2E7D32)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),

//                         // Password field
//                         TextField(
//                           controller: passwordController,
//                           obscureText: true,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             prefixIcon: const Icon(Icons.lock, color: Color(0xFF2E7D32)),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF2E7D32)),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
//                             ),
//                           ),
//                         ),

//                         // Confirm password field (only for signup)
//                         if (!isLoginMode) ...[
//                           const SizedBox(height: 20),
//                           TextField(
//                             controller: confirmPasswordController,
//                             obscureText: true,
//                             decoration: InputDecoration(
//                               labelText: 'Confirm Password',
//                               prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Color(0xFF2E7D32)),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
//                               ),
//                             ),
//                           ),
//                         ],

//                         const SizedBox(height: 40),

//                         // Submit button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             onPressed: handleSubmit,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF2E7D32),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               elevation: 3,
//                             ),
//                             child: Text(
//                               isLoginMode ? 'Login' : 'Sign Up',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 20),

//                         // Toggle between login and signup
//                         TextButton(
//                           onPressed: toggleMode,
//                           child: RichText(
//                             text: TextSpan(
//                               style: TextStyle(color: Colors.grey[600], fontSize: 16),
//                               children: [
//                                 TextSpan(
//                                   text: isLoginMode 
//                                     ? "Don't have an account? " 
//                                     : "Already have an account? ",
//                                 ),
//                                 TextSpan(
//                                   text: isLoginMode ? 'Sign Up' : 'Login',
//                                   style: const TextStyle(
//                                     color: Color(0xFF2E7D32),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoginMode = true;
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final Color primaryColor = const Color(0xFF6B73FF);
  final Color titleColor = const Color(0xFF4834D4);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void handleSubmit() {
    // Navigates to the route named '/home' defined in your main.dart
    Navigator.pushReplacementNamed(context, '/home'); 
  }

  void toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      emailController.clear();
      passwordController.clear();
      nameController.clear();
      confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- PLAYFUL HEADING ---
                  const Text(
                    "CHILDREN STORY\nGENERATOR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900, // Fixed 'black' error
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black26,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Space between heading and card

                  // --- LOGIN CONTAINER ---
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500), 
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 45),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: primaryColor.withOpacity(0.1),
                            child: Icon(
                              isLoginMode ? Icons.auto_stories : Icons.face,
                              size: 40,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isLoginMode ? 'Welcome Back!' : 'Create Account',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 30),

                          if (!isLoginMode) ...[
                            _buildTextField(
                              controller: nameController,
                              label: 'Full Name',
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildTextField(
                            controller: emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),

                          if (!isLoginMode) ...[
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: confirmPasswordController,
                              label: 'Confirm Password',
                              icon: Icons.verified_user_outlined,
                              isPassword: true,
                            ),
                          ],

                          const SizedBox(height: 35),

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                isLoginMode ? 'LOGIN' : 'SIGN UP',
                                style: const TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),

                          GestureDetector(
                            onTap: toggleMode,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                children: [
                                  TextSpan(text: isLoginMode ? "New here? " : "Already joined? "),
                                  TextSpan(
                                    text: isLoginMode ? 'Sign Up' : 'Login',
                                    style: TextStyle(
                                      color: primaryColor, 
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}