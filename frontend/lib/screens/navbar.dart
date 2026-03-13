import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;

  const Navbar({
    Key? key,
    this.currentPage = 'home',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      centerTitle: true,
      toolbarHeight: 80,

      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNavButton(
            context: context,
            label: 'Home',
            isActive: currentPage == 'home',
            onPressed: () => Navigator.pushNamed(context, '/home'),
          ),

          const SizedBox(width: 40),

          _buildNavButton(
            context: context,
            label: 'Create Story',
            isActive: currentPage == 'story-input',
            onPressed: () => Navigator.pushNamed(context, '/story-input'),
          ),

          const SizedBox(width: 40),

          _buildNavButton(
            context: context,
            label: 'My Stories',
            isActive: currentPage == 'my-stories',
            onPressed: () => Navigator.pushNamed(context, '/my-stories'),
          ),

          const SizedBox(width: 40),

          _buildNavButton(
            context: context,
            label: 'Profile',
            isActive: currentPage == 'profile',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),

          const SizedBox(width: 40),

          _buildNavButton(
            context: context,
            label: 'Logout',
            isActive: false,
            onPressed: () {
              AuthService.logout();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required BuildContext context,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          decoration: isActive
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: Colors.amber,
          decorationThickness: 2,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}