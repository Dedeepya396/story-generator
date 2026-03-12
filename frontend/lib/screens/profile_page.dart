// import 'package:flutter/material.dart';
// import '../services/auth_service.dart';
// import 'navbar.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Profile Page',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true),
//       home: const ProfilePage(),
//     );
//   }
// }

// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchProfile();
//   }

//   Future<void> _fetchProfile() async {
//     // If we have a user but no storyCount (older login/session), force a fetch
//     if (AuthService.user != null && AuthService.user!['storyCount'] != null) {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//       return;
//     }

//     final result = await AuthService.getUserProfile();
//     if (mounted) {
//       setState(() {
//         isLoading = false;
//         if (!result["success"]) {
//           errorMessage = result["message"];
//         }
//       });
//     }
//   }

//   Future<void> _showEditProfileDialog() async {
//     final user = AuthService.user;
//     final currentName = user?['fullName'] ?? user?['name'] ?? "";
//     final currentEmail = user?['email'] ?? "";
//     final nameController = TextEditingController(text: currentName);
//     final emailController = TextEditingController(text: currentEmail);
//     final passwordController = TextEditingController();
//     bool isSaving = false;

//     return showDialog(
//       context: context,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) => AlertDialog(
//           backgroundColor: const Color(0xFFFFF3DC),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Text(
//             "Edit Profile",
//             style: TextStyle(color: Color(0xFF3B2308), fontWeight: FontWeight.bold),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 style: const TextStyle(color: Color(0xFF3B2308)),
//                 decoration: InputDecoration(
//                   labelText: "Full Name",
//                   labelStyle: const TextStyle(color: Color(0xFF7A5230)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: const BorderSide(color: Color(0xFF6C63FF)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: emailController,
//                 style: const TextStyle(color: Color(0xFF3B2308)),
//                 decoration: InputDecoration(
//                   labelText: "Email",
//                   labelStyle: const TextStyle(color: Color(0xFF7A5230)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: const BorderSide(color: Color(0xFF6C63FF)),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 style: const TextStyle(color: Color(0xFF3B2308)),
//                 decoration: InputDecoration(
//                   labelText: "New Password",
//                   hintText: "Leave blank to keep current",
//                   labelStyle: const TextStyle(color: Color(0xFF7A5230)),
//                   hintStyle: TextStyle(color: const Color(0xFF7A5230).withOpacity(0.5)),
//                   focusedBorder: UnderlineInputBorder(
//                     borderSide: const BorderSide(color: Color(0xFF6C63FF)),
//                   ),
//                 ),
//               ),
//               if (isSaving)
//                 const Padding(
//                   padding: EdgeInsets.only(top: 16),
//                   child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: isSaving ? null : () => Navigator.pop(context),
//               child: const Text("Cancel", style: TextStyle(color: Color(0xFF7A5230))),
//             ),
//             ElevatedButton(
//               onPressed: isSaving
//                   ? null
//                   : () async {
//                       final newName = nameController.text.trim();
//                       final newEmail = emailController.text.trim();
//                       final newPassword = passwordController.text.trim();

//                       if (newName.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Name cannot be empty")),
//                         );
//                         return;
//                       }

//                       if (newEmail.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text("Email cannot be empty")),
//                         );
//                         return;
//                       }

//                       setDialogState(() => isSaving = true);

//                       final result = await AuthService.updateUserProfile(
//                         name: newName,
//                         email: newEmail,
//                         password: newPassword.isNotEmpty ? newPassword : null,
//                       );

//                       if (mounted) {
//                         setDialogState(() => isSaving = false);
//                         if (result["success"]) {
//                           Navigator.pop(context);
//                           setState(() {}); // Refresh ProfilePage
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text("Profile updated successfully")),
//                           );
//                         } else {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text(result["message"] ?? "Update failed")),
//                           );
//                         }
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6C63FF),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text("Save"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         appBar: Navbar(currentPage: 'home'),
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (errorMessage != null && AuthService.user == null) {
//       return Scaffold(
//         appBar: Navbar(currentPage: 'home'),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text("Error: $errorMessage"),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     isLoading = true;
//                     errorMessage = null;
//                   });
//                   _fetchProfile();
//                 },
//                 child: const Text("Retry"),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     final user = AuthService.user;
//     final userName = user?['fullName'] ?? user?['name'] ?? "Story Creator";
//     final userEmail = user?['email'] ?? "No Email";
//     final storyCount = user?['storyCount'] ?? 0;
//     final userRole = user?['role'] ?? "Creative Storyteller";

//     final size = MediaQuery.of(context).size;


//     return Scaffold(
//       appBar: Navbar(currentPage: 'home'),
//       body: Stack(
//         children: [
//           // ── Full-screen background image ───────────────────────────────
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/profile_page_bg.png',
//               // ↑ Place your bamboo-frame image here.
//               // For quick testing you can swap to:
//               // Image.network('https://...')
//               // fit: BoxFit.contain,
//               fit: BoxFit.fill,
//             ),
//           ),
//           // ── Positioned 1: Avatar + Name + Edit Profile (centered in board) ──
// Positioned(
//   top: size.height * 0.24,
//   left: size.width * 0.12,
//   right: size.width * 0.08,
//   child: Column(
//     mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Container(
//         padding: const EdgeInsets.all(3),
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: const LinearGradient(
//             colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.28),
//               blurRadius: 14,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: CircleAvatar(
//           radius: 40,
//           backgroundImage: NetworkImage(
//             "https://api.dicebear.com/7.x/adventurer/png?seed=$userName&backgroundColor=b6e3f4,c0aede,d1d4f9&size=200",
//           ),
//         ),
//       ),

//       const SizedBox(height: 10),

//       Text(
//         userName,
//         style: const TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.w900,
//           color: Color(0xFF3B2308),
//           letterSpacing: 0.4,
//         ),
//       ),

//       const SizedBox(height: 2),

//       Text(
//         userRole,
//         style: const TextStyle(
//           fontSize: 12,
//           color: Color(0xFF7A5230),
//           fontWeight: FontWeight.w600,
//           letterSpacing: 0.5,
//         ),
//       ),

//       const SizedBox(height: 10),

//       OutlinedButton.icon(
//         onPressed: _showEditProfileDialog,
//         icon: const Icon(Icons.edit_outlined, size: 14),
//         label: const Text('Edit Profile'),
//         style: OutlinedButton.styleFrom(
//           foregroundColor: const Color(0xFF5B3A18),
//           backgroundColor: Colors.white.withOpacity(0.5),
//           side: const BorderSide(color: Color(0xFF7A5230), width: 1.4),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
//           textStyle: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//     ],
//   ),
// ),

// // ── Positioned 2: Information + Connect sections (left aligned in board) ──
// Positioned(
//   top: size.height * 0.40,     // starts below the avatar section
//   bottom: size.height * 0.28,  // stops above cartoon kids
//   left: size.width * 0.25,     // inside left bamboo frame
//   right: size.width * 0.08,    // inside right bamboo frame
//   child: SingleChildScrollView(
//     physics: const BouncingScrollPhysics(),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [

//         // Information Section
//         const _Label('Information', fontSize: 30),
//         const SizedBox(height: 15),
//         _InfoRow(
//           icon: Icons.email_outlined,
//           label: 'Email',
//           value: userEmail,
//         ),
//         const SizedBox(height: 15),
//         _InfoRow(
//           icon: Icons.folder_outlined,
//           label: 'Projects',
//           value: '$storyCount Story Videos Created',
//         ),
//       ],


//     ),
//   ),
// ),
//         ],
//       ),
//     );
//   }

//   Widget _cardDivider() => Divider(
//       height: 18,
//       color: const Color(0xFF7A5230).withOpacity(0.18),
//       thickness: 1);
// }


// /// Parchment-toned translucent card that blends with the board texture
// class _BoardCard extends StatelessWidget {
//   final Widget child;
//   const _BoardCard({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         // Warm parchment tint, semi-transparent so board texture shows through
//         color: const Color(0xFFFFF3DC).withOpacity(0.52),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: const Color(0xFF8B6330).withOpacity(0.28),
//           width: 1,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.07),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: child,
//     );
//   }
// }

// // class _Label extends StatelessWidget {
// //   final String text;
// //   const _Label(this.text);

// //   @override
// //   Widget build(BuildContext context) => Text(
// //         text,
// //         style: const TextStyle(
// //           fontSize: 14,
// //           fontWeight: FontWeight.w900,
// //           color: Color(0xFF3B2308),
// //           letterSpacing: 0.3,
// //         ),
// //       );
// // }

// class _Label extends StatelessWidget {
//   final String text;
//   final double fontSize;                          // ← add this
//   const _Label(this.text, {this.fontSize = 14}); // ← default is 14

//   @override
//   Widget build(BuildContext context) => Text(
//         text,
//         style: TextStyle(
//           fontSize: fontSize,        // ← uses the passed value
//           fontWeight: FontWeight.w900,
//           color: const Color(0xFF3B2308),
//           letterSpacing: 0.3,
//         ),
//       );
// }

// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   const _InfoRow(
//       {required this.icon, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) => Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, size: 20, color: const Color(0xFF7A5230)),
//               const SizedBox(width: 4),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 20,
//                   color: Color(0xFF7A5230),
//                   fontWeight: FontWeight.w700,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 3),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Color(0xFF3B2308),
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       );
// }

// class _SocialBtn extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   const _SocialBtn(
//       {required this.icon, required this.color, required this.bg});

//   @override
//   Widget build(BuildContext context) => Container(
//         width: 44,
//         height: 44,
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.22),
//               blurRadius: 8,
//               offset: const Offset(0, 3),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: color, size: 22),
//       );
// }

// class _StatPill extends StatelessWidget {
//   final String label;
//   final String value;
//   const _StatPill({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) => Expanded(
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF6C63FF).withOpacity(0.35),
//                 blurRadius: 10,
//                 offset: const Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 label,
//                 style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.white.withOpacity(0.88),
//                     fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       );
// }

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? errorMessage;

  // ── ADDED: Avatar list (network URLs) + default ──────────────────────
  final List<String> _avatarList = [
    'https://api.dicebear.com/7.x/adventurer/png?seed=Felix&size=200',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Aneka&size=200',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Lily&size=200',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Max&size=200',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Sophie&size=200',
    'https://api.dicebear.com/7.x/adventurer/png?seed=Jake&size=200',
  ];
  // Default avatar = first one; changes when user picks
  String _selectedAvatar =
      'https://api.dicebear.com/7.x/adventurer/png?seed=Felix&size=200';
  // ────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    // If we have a user but no storyCount (older login/session), force a fetch
    if (AuthService.user != null && AuthService.user!['storyCount'] != null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }

    final result = await AuthService.getUserProfile();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (!result["success"]) {
          errorMessage = result["message"];
        }
      });
    }
  }

  // ── ADDED: Avatar picker bottom sheet ────────────────────────────────
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFF3DC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min, // prevents overflow
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF7A5230).withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Choose Your Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF3B2308),
              ),
            ),

            const SizedBox(height: 20),

            // Avatar grid — 3 columns, wrapped in Flexible to prevent overflow
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _avatarList.length,
                itemBuilder: (context, index) {
                  final avatar = _avatarList[index];
                  final isSelected = _selectedAvatar == avatar;

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAvatar = avatar);
                      Navigator.pop(context); // close bottom sheet
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Purple-pink ring on selected avatar
                        gradient: isSelected
                            ? const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFFFF6584),
                                ],
                              )
                            : null,
                        border: isSelected
                            ? null
                            : Border.all(
                                color: const Color(0xFF7A5230)
                                    .withOpacity(0.3),
                                width: 2,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF)
                                      .withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      padding:
                          isSelected ? const EdgeInsets.all(3) : null,
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                        backgroundColor: const Color(0xFFEDD9B0),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  // ────────────────────────────────────────────────────────────────────

  Future<void> _showEditProfileDialog() async {
    final user = AuthService.user;
    final currentName = user?['fullName'] ?? user?['name'] ?? "";
    final currentEmail = user?['email'] ?? "";
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final passwordController = TextEditingController();
    bool isSaving = false;

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3DC),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Edit Profile",
            style: TextStyle(
                color: Color(0xFF3B2308), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Color(0xFF3B2308)),
                decoration: InputDecoration(
                  labelText: "Full Name",
                  labelStyle: const TextStyle(color: Color(0xFF7A5230)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Color(0xFF3B2308)),
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: const TextStyle(color: Color(0xFF7A5230)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Color(0xFF3B2308)),
                decoration: InputDecoration(
                  labelText: "New Password",
                  hintText: "Leave blank to keep current",
                  labelStyle: const TextStyle(color: Color(0xFF7A5230)),
                  hintStyle: TextStyle(
                      color: const Color(0xFF7A5230).withOpacity(0.5)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        const BorderSide(color: Color(0xFF6C63FF)),
                  ),
                ),
              ),
              if (isSaving)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(
                      color: Color(0xFF6C63FF)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text("Cancel",
                  style: TextStyle(color: Color(0xFF7A5230))),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      final newName = nameController.text.trim();
                      final newEmail = emailController.text.trim();
                      final newPassword = passwordController.text.trim();

                      if (newName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Name cannot be empty")),
                        );
                        return;
                      }

                      if (newEmail.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Email cannot be empty")),
                        );
                        return;
                      }

                      setDialogState(() => isSaving = true);

                      final result = await AuthService.updateUserProfile(
                        name: newName,
                        email: newEmail,
                        password:
                            newPassword.isNotEmpty ? newPassword : null,
                      );

                      if (mounted) {
                        setDialogState(() => isSaving = false);
                        if (result["success"]) {
                          Navigator.pop(context);
                          setState(() {}); // Refresh ProfilePage
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Profile updated successfully")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    result["message"] ?? "Update failed")),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        appBar: Navbar(currentPage: 'home'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null && AuthService.user == null) {
      return Scaffold(
        appBar: Navbar(currentPage: 'home'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $errorMessage"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  _fetchProfile();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final user = AuthService.user;
    final userName = user?['fullName'] ?? user?['name'] ?? "Story Creator";
    final userEmail = user?['email'] ?? "No Email";
    final storyCount = user?['storyCount'] ?? 0;
    final userRole = user?['role'] ?? "Creative Storyteller";

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: Navbar(currentPage: 'home'),
      body: Stack(
        children: [
          // ── Full-screen background image ─────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/profile_page_bg.png',
              fit: BoxFit.fill,
            ),
          ),

          // ── Positioned 1: Information section (unchanged) ────────────
          Positioned(
            top: size.height * 0.40,
            bottom: size.height * 0.28,
            left: size.width * 0.25,
            right: size.width * 0.08,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Information', fontSize: 30),
                  const SizedBox(height: 15),
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: userEmail,
                  ),
                  const SizedBox(height: 15),
                  _InfoRow(
                    icon: Icons.folder_outlined,
                    label: 'Projects',
                    value: '$storyCount Story Videos Created',
                  ),
                ],
              ),
            ),
          ),

          // ── Positioned 2: Avatar + Name + Edit Profile ───────────────
          Positioned(
            top: size.height * 0.24,
            left: size.width * 0.12,
            right: size.width * 0.08,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── ADDED: GestureDetector + Stack for camera badge ──
                GestureDetector(
                  onTap: _showAvatarPicker, // tap to open avatar picker
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6C63FF),
                              Color(0xFFFF6584),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        // CHANGED: uses _selectedAvatar instead of fixed URL
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(_selectedAvatar),
                          backgroundColor: const Color(0xFFEDD9B0),
                        ),
                      ),
                      // Camera badge — hints user the avatar is tappable
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF6C63FF),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // ────────────────────────────────────────────────────

                const SizedBox(height: 10),

                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF3B2308),
                    letterSpacing: 0.4,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  userRole,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A5230),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 10),

                OutlinedButton.icon(
                  onPressed: _showEditProfileDialog,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF5B3A18),
                    backgroundColor: Colors.white.withOpacity(0.5),
                    side: const BorderSide(
                        color: Color(0xFF7A5230), width: 1.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 7),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardDivider() => Divider(
      height: 18,
      color: const Color(0xFF7A5230).withOpacity(0.18),
      thickness: 1);
}

// ── Reusable Widgets (all unchanged) ─────────────────────────────────────

class _BoardCard extends StatelessWidget {
  final Widget child;
  const _BoardCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DC).withOpacity(0.52),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8B6330).withOpacity(0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final double fontSize;
  const _Label(this.text, {this.fontSize = 14});

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF3B2308),
          letterSpacing: 0.3,
        ),
      );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF7A5230)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF7A5230),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF3B2308),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
}

class _SocialBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  const _SocialBtn(
      {required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.22),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      );
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6C63FF).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.88),
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
}