import 'package:flutter/material.dart';
import 'my_stories.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout - side by side on tablets/desktop, stacked on mobile
            if (constraints.maxWidth > 600) {
              return _buildTabletLayout(context);
            } else {
              return _buildMobileLayout(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side - Profile Section
        Expanded(
          flex: 2,
          child: _buildProfileSection(context),
        ),
        // Right Side - Information Section
        Expanded(
          flex: 3,
          child: _buildInformationSection(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileSection(context),
          _buildInformationSection(),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFFFFB84D),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Picture
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          "https://api.dicebear.com/7.x/adventurer/png?seed=Rishika&backgroundColor=b6e3f4,c0aede,d1d4f9&size=200",
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFB6E3F4),
                                    Color(0xFFC0AEDE),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFB6E3F4),
                                    Color(0xFFC0AEDE),
                                  ],
                                ),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD93D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.auto_stories,
                        color: Color(0xFFFF6B6B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Name
              const Text(
                "Rishika",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Role
              const Text(
                "Story Creator",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Edit Profile Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // TODO: Edit profile
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: Color(0xFFFF6B6B),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Edit Profile",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // My Stories Button
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD93D),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyStoriesPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book,
                                color: Color(0xFFFF6B6B),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "My Stories",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFF6B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Information Header
            const Text(
              "Information",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Email and Phone Row
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    title: "Email",
                    value: "rishika@gmail.com",
                    icon: Icons.email_outlined,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    title: "Phone",
                    value: "9897989898",
                    icon: Icons.phone_outlined,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Projects Section
            _buildInfoItem(
              title: "Projects",
              value: "12 Story Videos Created",
              icon: Icons.work_outline,
            ),
            
            const SizedBox(height: 32),
            
            // Recent and Most Viewed Row
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    title: "Recent",
                    value: "The Magic Garden",
                    icon: Icons.access_time,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildInfoItem(
                    title: "Most Viewed",
                    value: "Adventures in Space",
                    icon: Icons.visibility_outlined,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Social Media Links
            const Text(
              "Connect",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF636E72),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildSocialIcon(
                  icon: Icons.facebook,
                  color: const Color(0xFF1877F2),
                  onTap: () {
                    // TODO: Open Facebook
                  },
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  icon: Icons.camera_alt,
                  color: const Color(0xFF1DA1F2),
                  onTap: () {
                    // TODO: Open Twitter
                  },
                ),
                const SizedBox(width: 16),
                _buildSocialIcon(
                  icon: Icons.photo_camera,
                  color: const Color(0xFFE4405F),
                  onTap: () {
                    // TODO: Open Instagram
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFF636E72),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF636E72),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}

// Placeholder for My Stories Page
// class MyStoriesPage extends StatelessWidget {
//   const MyStoriesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Stories'),
//         backgroundColor: const Color(0xFFFF6B6B),
//         foregroundColor: Colors.white,
//       ),
//       body: const Center(
//         child: Text(
//           'My Stories Page',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }