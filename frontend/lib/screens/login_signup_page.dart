// import 'package:flutter/material.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   bool isLoginMode = true;
  
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   final Color primaryColor = const Color(0xFF6B73FF);
//   final Color titleColor = const Color(0xFF4834D4);

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     nameController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void handleSubmit() {
//     // Navigates to the route named '/home' defined in your main.dart
//     Navigator.pushReplacementNamed(context, '/home'); 
//   }

//   void toggleMode() {
//     setState(() {
//       isLoginMode = !isLoginMode;
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
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // --- PLAYFUL HEADING ---
//                   const Text(
//                     "CHILDREN STORY\nGENERATOR",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 38,
//                       fontWeight: FontWeight.w900, // Fixed 'black' error
//                       color: Colors.white,
//                       letterSpacing: 2,
//                       shadows: [
//                         Shadow(
//                           blurRadius: 10.0,
//                           color: Colors.black26,
//                           offset: Offset(2.0, 2.0),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 40), // Space between heading and card

//                   // --- LOGIN CONTAINER ---
//                   ConstrainedBox(
//                     constraints: const BoxConstraints(maxWidth: 500), 
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 45),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(30),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 20,
//                             offset: const Offset(0, 10),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircleAvatar(
//                             radius: 35,
//                             backgroundColor: primaryColor.withOpacity(0.1),
//                             child: Icon(
//                               isLoginMode ? Icons.auto_stories : Icons.face,
//                               size: 40,
//                               color: primaryColor,
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             isLoginMode ? 'Welcome Back!' : 'Create Account',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.w900,
//                               color: titleColor,
//                             ),
//                           ),
//                           const SizedBox(height: 30),

//                           if (!isLoginMode) ...[
//                             _buildTextField(
//                               controller: nameController,
//                               label: 'Full Name',
//                               icon: Icons.person_outline,
//                             ),
//                             const SizedBox(height: 16),
//                           ],

//                           _buildTextField(
//                             controller: emailController,
//                             label: 'Email Address',
//                             icon: Icons.email_outlined,
//                           ),
//                           const SizedBox(height: 16),

//                           _buildTextField(
//                             controller: passwordController,
//                             label: 'Password',
//                             icon: Icons.lock_outline,
//                             isPassword: true,
//                           ),

//                           if (!isLoginMode) ...[
//                             const SizedBox(height: 16),
//                             _buildTextField(
//                               controller: confirmPasswordController,
//                               label: 'Confirm Password',
//                               icon: Icons.verified_user_outlined,
//                               isPassword: true,
//                             ),
//                           ],

//                           const SizedBox(height: 35),

//                           SizedBox(
//                             width: double.infinity,
//                             height: 55,
//                             child: ElevatedButton(
//                               onPressed: handleSubmit,
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: primaryColor,
//                                 foregroundColor: Colors.white,
//                                 elevation: 5,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(15),
//                                 ),
//                               ),
//                               child: Text(
//                                 isLoginMode ? 'LOGIN' : 'SIGN UP',
//                                 style: const TextStyle(
//                                   fontSize: 16, 
//                                   fontWeight: FontWeight.bold,
//                                   letterSpacing: 1.1
//                                 ),
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 25),

//                           GestureDetector(
//                             onTap: toggleMode,
//                             child: RichText(
//                               text: TextSpan(
//                                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                                 children: [
//                                   TextSpan(text: isLoginMode ? "New here? " : "Already joined? "),
//                                   TextSpan(
//                                     text: isLoginMode ? 'Sign Up' : 'Login',
//                                     style: TextStyle(
//                                       color: primaryColor, 
//                                       fontWeight: FontWeight.bold,
//                                       decoration: TextDecoration.underline
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool isPassword = false,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: primaryColor),
//         filled: true,
//         fillColor: Colors.grey[50],
//         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: Colors.grey[200]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide(color: primaryColor, width: 2),
//         ),
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}


Future<void> saveLoginState() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', true);
}
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool isLoginMode = true;
  String? selectedRole;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final Color primaryColor = const Color(0xFF6366F1);
  final Color secondaryColor = const Color(0xFFF59E0B);
  final Color accentColor = const Color(0xFF10B981);
  final Color teacherColor = const Color(0xFF8B5CF6);
  final Color studentColor = const Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // void handleSubmit() {
  //   Navigator.pushReplacementNamed(context, '/home');
  // }
  Future<void> handleSubmit() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Map<String, dynamic> result;

    if (isLoginMode) {
      result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (result["success"]) {
        Navigator.pushReplacementNamed(context, '/home');
        saveLoginState();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Error")),
        );
      }
    } else {
      if (selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a role")),
        );
        return;
      }

      result = await AuthService.signup(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
        selectedRole!,
      );

      if (result["success"]) {
        // Show success dialog
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Success"),
              content: const Text("Signup successful! Please login to continue."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    toggleMode(); // Switch to login mode
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Error")),
        );
      }
    }
  }

  void toggleMode() {
    setState(() {
      isLoginMode = !isLoginMode;
      selectedRole = null;
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login.png'),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            // Main content - centered
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Title
                      // Role selection for signup
                      if (!isLoginMode) ...[
                        Text(
                          'I am a:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                blurRadius: 4.0,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 300,
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildRoleButton(
                                  label: '👨‍🏫 Teacher',
                                  color: teacherColor,
                                  isSelected: selectedRole == 'teacher',
                                  onTap: () => setState(
                                      () => selectedRole = 'teacher'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildRoleButton(
                                  label: '👨‍🎓 Student',
                                  color: studentColor,
                                  isSelected: selectedRole == 'student',
                                  onTap: () => setState(
                                      () => selectedRole = 'student'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                      ],
                      // Form Fields Container - minimal width
                      SizedBox(
                        width: 320,
                        child: Column(
                          children: [
                            // Name field (signup only)
                            if (!isLoginMode) ...[
                              _buildTransparentTextField(
                                controller: nameController,
                                label: '👤 Full Name',
                                hint: 'Enter your full name',
                              ),
                              const SizedBox(height: 16),
                            ],
                            // Email field
                            _buildTransparentTextField(
                              controller: emailController,
                              label: '📧 Email Address',
                              hint: 'your@email.com',
                            ),
                            const SizedBox(height: 16),
                            // Password field
                            _buildTransparentTextField(
                              controller: passwordController,
                              label: '🔐 Password',
                              hint: 'Enter your password',
                              isPassword: true,
                            ),
                            // Confirm password (signup only)
                            if (!isLoginMode) ...[
                              const SizedBox(height: 16),
                              _buildTransparentTextField(
                                controller: confirmPasswordController,
                                label: '✓ Confirm Password',
                                hint: 'Confirm your password',
                                isPassword: true,
                              ),
                            ],
                            const SizedBox(height: 28),
                            // Submit button
                            Container(
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isLoginMode
                                      ? [primaryColor, primaryColor.withOpacity(0.85)]
                                      : [secondaryColor, secondaryColor.withOpacity(0.85)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: isLoginMode
                                        ? primaryColor.withOpacity(0.5)
                                        : secondaryColor.withOpacity(0.5),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: handleSubmit,
                                  borderRadius: BorderRadius.circular(20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isLoginMode ? '🚀 Login' : '⭐ Create Account',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black87,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            // Toggle mode button
                            GestureDetector(
                              onTap: toggleMode,
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                  children: [
                                    TextSpan(
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.9),
                                      ),
                                      text: isLoginMode
                                          ? "New here? "
                                          : "Have an account? ",
                                    ),
                                    TextSpan(
                                      text: isLoginMode ? 'Sign Up' : 'Login',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 4.0,
                                            color: Colors.black54,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.3)
              : Colors.white.withOpacity(0.2),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.8)
                : Colors.white.withOpacity(0.4),
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: 0.2,
            shadows: [
              Shadow(
                blurRadius: 4.0,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.15),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
            ),
            suffixIcon: isPassword
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.lock_outline,
                      color: Colors.black.withOpacity(0.7),
                      size: 20,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}