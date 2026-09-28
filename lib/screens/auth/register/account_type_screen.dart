import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/register/register_screen.dart';

class AccountTypeScreen extends StatelessWidget {
  const AccountTypeScreen({super.key});

  void _openRegistration(BuildContext context, String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MyRegisterScreen(role: role)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Image.asset(AppIcons.icApp, height: 62, width: 180, fit: BoxFit.contain),
              const SizedBox(height: 42),
              const Text(
                'Which account do you want to create?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you will use NBFT Estates.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 34),
              _option(
                context,
                role: 'user',
                title: 'I am a User',
                subtitle: 'Find properties, save favourites and schedule visits.',
                icon: Icons.home_outlined,
              ),
              const SizedBox(height: 16),
              _option(
                context,
                role: 'broker',
                title: 'I am a Broker',
                subtitle: 'List properties and manage your customer leads.',
                icon: Icons.business_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(BuildContext context, {required String role, required String title, required String subtitle, required IconData icon}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _openRegistration(context, role),
      child: Ink(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.secondary, child: Icon(icon, color: AppColors.primary, size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 5), Text(subtitle, style: const TextStyle(color: AppColors.gray500, fontSize: 12, height: 1.3))])),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
