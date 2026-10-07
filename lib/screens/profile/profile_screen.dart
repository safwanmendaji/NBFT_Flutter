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

import '../../models/subscription/subscription_model.dart';
import '../../services/api/subscription_api.dart';
import '../user/manage_subscription_screen.dart';
import '../user/subscription_screen.dart';

class MyProfile extends StatefulWidget {
  final bool hideTopHeaders;

  const MyProfile({super.key, this.hideTopHeaders = false});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool isLoading = true;
  SubscriptionStatus? _subscription;
  DateTime? get _planStart => _subscription?.startDate;
  DateTime? get _planExpiry => _subscription?.endDate;

  int? get _daysRemaining => _planExpiry?.difference(DateTime.now()).inDays;

  String get _planName {
    final purpose = _subscription?.propertyPurpose;
    return purpose == null || purpose.isEmpty ? 'Membership plan' : '$purpose plan';
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await SubscriptionApi.getMySubscription(context: context);
      if (mounted) setState(() => _subscription = subscription);
    } catch (_) {
      final start = DateTime.tryParse(Prefs.getString(LocalStrings.subscriptionStart));
      final end = DateTime.tryParse(Prefs.getString(LocalStrings.subscriptionEnd));
      final cachedPurpose = Prefs.getString(LocalStrings.subscriptionPurpose);
      final purpose =
          cachedPurpose.isNotEmpty
              ? cachedPurpose
              : Prefs.getBool(LocalStrings.subscribedCommercial, false) == true
              ? 'Commercial'
              : Prefs.getBool(LocalStrings.subscribedResidential, false) == true
              ? 'Residential'
              : '';
      final isRefunded = false;
      if (mounted && (start != null || end != null || purpose.isNotEmpty)) {
        setState(() => _subscription = SubscriptionStatus(startDate: start, endDate: end, isRefunded: isRefunded, propertyPurpose: purpose));
      }
      isLoading = false;
      setState(() {});
    }
  }

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
              //const MyCustomHeaderLogo(),
              const MyCustomHeader(title: "Profile"),
            ],
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _profileHeader(name: userName.isEmpty ? 'User' : userName, email: userEmail.isEmpty ? 'user@email.com' : userEmail, userId: userId),
                    const SizedBox(height: 22),
                    if (Prefs.getString(LocalStrings.userrole, 'broker').toLowerCase() != 'broker') _membershipCard(),
                    const SizedBox(height: 18),
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

  Widget _membershipCard() {
    final days = _daysRemaining;

    final isActive = _subscription?.isActive == true;

    final progress =
        days != null && _planStart != null && _planExpiry != null && _planExpiry!.difference(_planStart!).inSeconds > 0
            ? (DateTime.now().difference(_planStart!).inSeconds / _planExpiry!.difference(_planStart!).inSeconds).clamp(0.0, 1.0)
            : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 20, top: 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.secondary, AppColors.secondary]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary, width: 1),
        boxShadow: [const BoxShadow(color: AppColors.secondary, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // TOP SECTION
          // ============================================================
          _planPill(),
          // LayoutBuilder(
          //   builder: (context, constraints) {
          //     final isSmall = constraints.maxWidth < 500;
          //
          //     if (isSmall) {
          //       return Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Row(children: [_membershipStatusPill(), const SizedBox(width: 10), Expanded(child: _planPill())]),
          //           const SizedBox(height: 8),
          //           //_planActions(),
          //         ],
          //       );
          //     }
          //
          //     return Row(children: [_membershipStatusPill(), const SizedBox(width: 12), Expanded(child: _planPill()), const SizedBox(width: 12), _planActions()]);
          //   },
          // ),

          // ============================================================
          // PLAN INFO
          // ============================================================
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Days
                Text(
                  days == null ? '--' : '${days.clamp(0, 9999)}',
                  style: const TextStyle(color: AppColors.contactus, fontSize: 42, height: .95, fontWeight: FontWeight.w800, letterSpacing: -1.5),
                ),

                const SizedBox(width: 8),

                const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text('days remaining', style: TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                ),

                const Spacer(),

                // Expiry
                if (_planExpiry != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('VALID UNTIL', style: TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
                      const SizedBox(height: 3),
                      Text(_formatDate(_planExpiry!), style: const TextStyle(color: AppColors.contactus, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
              ],
            ),
          ),

          // ============================================================
          // PROGRESS
          // ============================================================
          if (days != null && isActive) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Plan validity', style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600)),

                  Text('${(progress * 100).round()}% used', style: const TextStyle(color: AppColors.contactus, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            const SizedBox(height: 7),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  backgroundColor: Colors.white.withValues(alpha: .75),
                  value: progress,
                  valueColor: const AlwaysStoppedAnimation(AppColors.contactus),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_planStart == null ? '' : _formatDate(_planStart!), style: const TextStyle(color: AppColors.contactus, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(_planExpiry == null ? '' : _formatDate(_planExpiry!), style: const TextStyle(color: AppColors.contactus, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],

          // ============================================================
          // INACTIVE STATE
          // ============================================================
          if (!isActive) ...[
            const SizedBox(height: 4),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 17, color: Color(0xff747979)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Your membership is currently inactive.', style: TextStyle(color: Color(0xff626868), fontSize: 12, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _membershipStatusPill() {
    final isActive = _subscription?.isActive == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership', style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Text(isActive ? 'ACTIVE' : 'INACTIVE', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: .3)),
        ],
      ),
    );
  }

  Widget _planPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Your Membership Plan", maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: AppColors.contactus, fontSize: 18, fontWeight: FontWeight.w800)),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: AppColors.contactus.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                  icon: const Icon(Icons.edit, color: AppColors.white),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: AppColors.contactus.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionDetailsScreen())),
                  icon: const Icon(Icons.remove_red_eye_outlined, color: AppColors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Plan
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
          },
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                SizedBox(width: 4),
                Icon(Icons.edit_outlined, size: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),

        const SizedBox(width: 4),

        // Manage Plan
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionDetailsScreen()));
          },
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Manage', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // ---------------------------------------------------------- PROFILE HEADER

  Widget _profileHeader({required String name, required String email, required String userId}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF163E3A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x1A1F4F4A), blurRadius: 16, offset: Offset(0, 8))],
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
              border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(_getInitials(name), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.mail_outline_rounded, size: 13, color: Color(0xFFD7DCDA)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD7DCDA), fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                if (userId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.badge_outlined, size: 12, color: Color(0xFFD7DCDA)),
                      const SizedBox(width: 4),
                      Text(
                        'ID: ${userId.length > 8 ? userId.substring(userId.length - 8) : userId}',
                        style: const TextStyle(color: Color(0xFFD7DCDA), fontSize: 11, fontWeight: FontWeight.w500),
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
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MyEditProfile()));
            },
            child: Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
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
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray500, letterSpacing: 0.3)),
    );
  }

  // -------------------------------------------------------- PROFILE OPTIONS

  Widget _profileOptionsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < profileOption.length; i++) ...[
            _profileOptionTile(profileOption[i]),
            if (i != profileOption.length - 1) const Divider(height: 1, thickness: 1, indent: 68, color: Color(0xFFEFF2F2)),
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
              decoration: BoxDecoration(color: option['tint'] as Color, borderRadius: BorderRadius.circular(12)),
              child: Icon(option['icon'] as IconData, size: 20, color: option['color'] as Color),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option['name'] as String, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.blackColor)),
                  const SizedBox(height: 3),
                  Text(option['subtitle'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.gray500, fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            // Arrow
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.gray500),
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
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          _aboutTile(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', tint: const Color(0xFFEDE7F6), color: const Color(0xFF6A4FC7), onTap: () {}),
          const Divider(height: 1, thickness: 1, indent: 68, color: Color(0xFFEFF2F2)),
          _aboutTile(icon: Icons.description_outlined, label: 'Terms & Conditions', tint: const Color(0xFFE3F2FD), color: const Color(0xFF1976D2), onTap: () {}),
          const Divider(height: 1, thickness: 1, indent: 68, color: Color(0xFFEFF2F2)),
          _aboutTile(icon: Icons.info_outline_rounded, label: 'App Version', tint: const Color(0xFFE7F1EF), color: AppColors.primary, trailingText: 'v1.0.0', onTap: null),
        ],
      ),
    );
  }

  Widget _aboutTile({required IconData icon, required String label, required Color tint, required Color color, required VoidCallback? onTap, String? trailingText}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(height: 40, width: 40, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: color)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.blackColor))),
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gray500))
            else
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.gray500),
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
        icon: const Icon(Icons.logout_rounded, size: 19, color: Color(0xFFD9534F)),
        label: const Text('Log Out', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFFD9534F))),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          side: const BorderSide(color: Color(0xFFFFCDD2), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
