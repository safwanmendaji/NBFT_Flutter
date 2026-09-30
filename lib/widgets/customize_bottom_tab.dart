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
          ? const [MyNewHomeScreen(), MyPropertiesScreen(), BrokerLeadsScreen(), VisitsScreen(isBroker: true), MyProfile(hideTopHeaders: true)]
          : const [UserHomeDashboard(), UserInterestedScreen(), VisitsScreen(isBroker: false), MyProfile(hideTopHeaders: true)];

  @override
  void initState() {
    super.initState();
    isBroker = Prefs.getString(LocalStrings.userrole, 'broker').toLowerCase() == 'broker';
    if (isBroker && widget.from == 'AddProperty') currentIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: Column(children: [const UserTopHeader(), Expanded(child: children[currentIndex])])),
      bottomNavigationBar: BottomNavBar(
        isBroker: isBroker,
        currentIndex: currentIndex,
        onTap: (int value) {
          print("CCC-${value}");
          currentIndex = value;
          setState(() {});
        },
      ),
      // bottomNavigationBar: Container(
      //   color: AppColors.primary,
      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       if (isBroker) ...[
      //         _menuItem(Icons.home_rounded, 'Dashboard', 0),
      //         _menuItem(Icons.apartment_outlined, 'Properties', 1),
      //         _menuItem(Icons.groups_outlined, 'Leads', 2),
      //         _menuItem(Icons.access_time_outlined, 'Visits', 3),
      //         _menuItem(Icons.more_horiz, 'More', 4),
      //       ] else ...[
      //         _menuItem(Icons.home_rounded, 'Home', 0),
      //         _menuItem(Icons.favorite_border_rounded, 'Interested', 1),
      //         _menuItem(Icons.event_available_outlined, 'Visit', 2),
      //         _menuItem(Icons.menu_rounded, 'Menu', 3),
      //       ],
      //     ],
      //   ),
      // ),
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
          decoration: BoxDecoration(color: selected ? AppColors.secondary : Colors.transparent, borderRadius: BorderRadius.circular(14)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.white),
              const SizedBox(height: 4),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? AppColors.primary : AppColors.white, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isBroker;

  const BottomNavBar({super.key, required this.currentIndex, required this.onTap, required this.isBroker});

  @override
  Widget build(BuildContext context) {
    const Color activeColor = Color(0xFF064D43);
    const Color inactiveColor = Color(0xFF4F5963);

    final items = [
      if (isBroker) ...[
        const _NavItem(icon: Icons.home_rounded, label: 'Home'),
        const _NavItem(icon: Icons.search_rounded, label: 'Search'),
        const _NavItem(icon: Icons.favorite_border_rounded, label: 'Shortlisted'),
        const _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
      ] else ...[
        const _NavItem(icon:Icons.home_rounded,label: 'Home'),
        const _NavItem(icon:Icons.favorite_border_rounded,label: 'Interested'),
        const _NavItem(icon:Icons.event_available_outlined, label:'Visit'),
        const _NavItem(icon:Icons.menu_rounded,label: 'Menu'),
      ],
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        //borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 82,
          child: Row(
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[index].icon, size: 28, color: isSelected ? activeColor : inactiveColor),

                      const SizedBox(height: 5),

                      Text(items[index].label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? activeColor : inactiveColor)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
