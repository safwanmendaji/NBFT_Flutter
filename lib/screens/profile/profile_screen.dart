import 'package:flutter/material.dart';

import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/dialogs/dialogue.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/account/account.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/change_password/change_password.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/edit_profile/edit_profile.dart';
import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:flutter_nobrokeragefortenants/widgets/header.dart';

class MyProfile extends StatefulWidget {
  final bool hideTopHeaders;

  const MyProfile({super.key, this.hideTopHeaders = false});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final List<Map<String, dynamic>> profileOption = [
    {
      'name': 'Edit Profile',
      'subtitle': 'Update your personal information',
      'icon': Icons.person_outline_rounded,
      'route': const MyEditProfile(),
      'tint': const Color(0xFFE7F1EF),
      'color': AppColors.primary,
    },
    {
      'name': 'Change Password',
      'subtitle': 'Keep your account secure',
      'icon': Icons.lock_outline_rounded,
      'route': const MyChangePassword(),
      'tint': const Color(0xFFFFF3E0),
      'color': const Color(0xFFC68A2E),
    },
    {
      'name': 'Account',
      'subtitle': 'Manage your account settings',
      'icon': Icons.manage_accounts_outlined,
      'route': const MyAccount(),
      'tint': const Color(0xFFE3F2FD),
      'color': const Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final userName = Prefs.getString(LocalStrings.username);
    final userEmail = Prefs.getString(LocalStrings.useremail);
    final userId = Prefs.getString(LocalStrings.userid);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            if (!widget.hideTopHeaders) ...[
              const MyCustomHeaderLogo(),
              const MyCustomHeader(title: "Profile"),
            ],
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(
                      name: userName.isEmpty ? 'User' : userName,
                      email: userEmail.isEmpty ? 'user@email.com' : userEmail,
                      userId: userId,
                    ),
                    const SizedBox(height: 22),

                    _sectionLabel('Account Settings'),
                    const SizedBox(height: 10),
                    _profileOptionsCard(),
                    const SizedBox(height: 22),

                    _sectionLabel('About'),
                    const SizedBox(height: 10),
                    _aboutCard(),
                    const SizedBox(height: 26),

                    _logoutButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- PROFILE HEADER

  Widget _profileHeader({
    required String name,
    required String email,
    required String userId,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF163E3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A1F4F4A),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            height: 64,
            width: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              _getInitials(name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 13,
                      color: Color(0xFFD7DCDA),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFD7DCDA),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (userId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_outlined,
                        size: 12,
                        color: Color(0xFFD7DCDA),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${userId.length > 8 ? userId.substring(userId.length - 8) : userId}',
                        style: const TextStyle(
                          color: Color(0xFFD7DCDA),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Edit icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyEditProfile()),
              );
            },
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  // ----------------------------------------------------------- SECTION LABEL

  Widget _sectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.gray500,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // -------------------------------------------------------- PROFILE OPTIONS

  Widget _profileOptionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < profileOption.length; i++) ...[
            _profileOptionTile(profileOption[i]),
            if (i != profileOption.length - 1)
              const Divider(
                height: 1,
                thickness: 1,
                indent: 68,
                color: Color(0xFFEFF2F2),
              ),
          ],
        ],
      ),
    );
  }

  Widget _profileOptionTile(Map<String, dynamic> option) {
    return InkWell(
      onTap: () {
        final route = option['route'];
        if (route != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => route));
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            // Icon container
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: option['tint'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option['icon'] as IconData,
                size: 20,
                color: option['color'] as Color,
              ),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['name'] as String,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option['subtitle'] as String,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 13,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- ABOUT

  Widget _aboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _aboutTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            tint: const Color(0xFFEDE7F6),
            color: const Color(0xFF6A4FC7),
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            color: Color(0xFFEFF2F2),
          ),
          _aboutTile(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            tint: const Color(0xFFE3F2FD),
            color: const Color(0xFF1976D2),
            onTap: () {},
          ),
          const Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            color: Color(0xFFEFF2F2),
          ),
          _aboutTile(
            icon: Icons.info_outline_rounded,
            label: 'App Version',
            tint: const Color(0xFFE7F1EF),
            color: AppColors.primary,
            trailingText: 'v1.0.0',
            onTap: null,
          ),
        ],
      ),
    );
  }

  Widget _aboutTile({
    required IconData icon,
    required String label,
    required Color tint,
    required Color color,
    required VoidCallback? onTap,
    String? trailingText,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: tint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppColors.gray500,
              ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------- LOGOUT

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => showLogoutDialog(context),
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
          color: Color(0xFFD9534F),
        ),
        label: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFFD9534F),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
