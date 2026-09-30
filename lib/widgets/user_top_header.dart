import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/screens/profile/profile_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/notifications/notifications_screen.dart';

class UserTopHeader extends StatelessWidget {
  const UserTopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xfffaf9f6), border: Border(bottom: BorderSide(color: Color(0xffe6e1d6)))),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          Image.asset(AppIcons.icApp, height: 42, width: 118, color: AppColors.blackColor, fit: BoxFit.contain),
          const Spacer(),
          IconButton(
            onPressed: () {
              final isBroker = Prefs.getString(LocalStrings.userrole, 'broker').toLowerCase() == 'broker';
              Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen(isBroker: isBroker)));
            },
            icon: const Icon(Icons.notifications_none_rounded, size: 24),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProfile())),
            child: const CircleAvatar(radius: 17, backgroundColor: AppColors.primary, child: Icon(Icons.person_outline, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }
}
