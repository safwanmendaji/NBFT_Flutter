import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/screens/home/home_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/leads/leads_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/profile/profile_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/properties/properties_screen.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/screens/user/user_dashboard.dart';
 import 'package:flutter_nobrokeragefortenants/screens/user/user_tabs.dart';
 import 'package:flutter_nobrokeragefortenants/screens/visits/visits_screen.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/user_top_header.dart';

class PrimaryBottomTab extends StatefulWidget {
  final String? from;
  const PrimaryBottomTab({super.key, this.from});

  @override
  State<PrimaryBottomTab> createState() => _PrimaryBottomTabState();
}

class _PrimaryBottomTabState extends State<PrimaryBottomTab> {
  int currentIndex = 0;
  late final bool isBroker;

  List<Widget> get children =>
      isBroker
          ? const [
            MyNewHomeScreen(),
            MyPropertiesScreen(),
            BrokerLeadsScreen(),
            VisitsScreen(isBroker: true),
            MyProfile(hideTopHeaders: true),
          ]
          : const [
            UserHomeDashboard(),
            UserInterestedScreen(),
            VisitsScreen(isBroker: false),
            MyProfile(hideTopHeaders: true),
          ];

  @override
  void initState() {
    super.initState();
    isBroker =
        Prefs.getString(LocalStrings.userrole, 'broker').toLowerCase() ==
        'broker';
    if (isBroker && widget.from == 'AddProperty') currentIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const UserTopHeader(),
            Expanded(child: children[currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            if (isBroker) ...[
              _menuItem(Icons.home_rounded, 'Dashboard', 0),
              _menuItem(Icons.apartment_outlined, 'Properties', 1),
              _menuItem(Icons.groups_outlined, 'Leads', 2),
              _menuItem(Icons.access_time_outlined, 'Visits', 3),
              _menuItem(Icons.more_horiz, 'More', 4),
            ] else ...[
              _menuItem(Icons.home_rounded, 'Home', 0),
              _menuItem(Icons.favorite_border_rounded, 'Interested', 1),
              _menuItem(Icons.event_available_outlined, 'Visit', 2),
              _menuItem(Icons.menu_rounded, 'Menu', 3),
            ],
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, int index) {
    final selected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => currentIndex = index),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.secondary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.white),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
