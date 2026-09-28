import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/login/login_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/user/subscription_screen.dart';
import 'package:flutter_nobrokeragefortenants/services/subscription_gate.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_bottom_tab.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  bool _restoringSession = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final token = Prefs.getString(LocalStrings.usertoken);
    if (token.isEmpty || !_isTokenValid(token)) {
      if (token.isNotEmpty) await Prefs.clear();
      if (mounted) setState(() => _restoringSession = false);
      return;
    }

    final role = Prefs.getString(LocalStrings.userrole).toLowerCase();
    final isUser = role == 'user' || role == 'tenant';
    if (!isUser) {
      _openSession(const PrimaryBottomTab());
      return;
    }

    final subscription = await SubscriptionGate.refresh(context);
    if (!mounted) return;
    final cachedSubscription = Prefs.getBool(LocalStrings.subscribedCommercial, false) == true || Prefs.getBool(LocalStrings.subscribedResidential, false) == true;
    _openSession(subscription?.isActive == true || cachedSubscription ? const PrimaryBottomTab() : const SubscriptionScreen());
  }

  bool _isTokenValid(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    try {
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final expiry = payload['exp'];
      if (expiry is num) {
        return DateTime.now().millisecondsSinceEpoch ~/ 1000 < expiry;
      }
    } catch (_) {
      return true;
    }
    return true;
  }

  void _openSession(Widget screen) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => screen), (_) => false);
  }

  void _goToLogin() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyLoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    if (_restoringSession) {
      return const Scaffold(backgroundColor: Color(0xFF163E3A), body: Center(child: CircularProgressIndicator(color: Color(0xFFE8C98B))));
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Opacity(opacity: 0.4, child: Image.asset('assets/images/bg.jpeg', fit: BoxFit.cover))),
          LayoutBuilder(
            builder:
                (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 72),
                              _buildBrand(),
                              const SizedBox(height: 26),
                              //const SizedBox(width: 320, height: 112, child: CustomPaint(painter: SkylinePainter())),
                              const SizedBox(height: 70),
                              const Text(
                                'No Brokerage.\nJust Honest Rentals.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700, height: 1.08, letterSpacing: -0.7),
                              ),
                              const SizedBox(height: 50),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.blackColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(20)),
                                child: const Text(
                                  'Find verified properties, connect with\nbrokers and schedule visits — all\nwithout paying brokerage.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white, fontSize: 16, height: 1.38, fontWeight: FontWeight.w400),
                                ),
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: _goToLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.secondwhite,
                                      foregroundColor: const Color(0xFF1E3E3B),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: const Text('Get Started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, letterSpacing: -0.2)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: GestureDetector(
                                  onTap: _goToLogin,
                                  child: const Text.rich(
                                    TextSpan(
                                      text: 'Already have an account? ',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
                                      children: [TextSpan(text: 'Login', style: TextStyle(color: Color(0xFFE8C98B), fontWeight: FontWeight.w700))],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset("assets/images/logo_copy.png", fit: BoxFit.fitWidth, height: 120, width: 300, color: AppColors.white),
            // SizedBox(
            //   width: 92,
            //   height: 92,
            //   child: Stack(
            //     children: [
            //       const Positioned.fill(child: CustomPaint(painter: HouseLogoPainter(strokeColor: Color(0xFFE6C77A)))),
            //       Positioned(
            //         bottom: 8,
            //         left: 20,
            //         child: Transform.translate(offset: const Offset(0, 8), child: const Text('R', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w700, color: Color(0xFFE6C77A), height: 1))),
            //       ),
            //     ],
            //   ),
            // ),
            //const SizedBox(width: 18),
            //const Text('NBFT', style: TextStyle(color: Color(0xFFE6C77A), fontSize: 54, fontWeight: FontWeight.w700, letterSpacing: -3, height: 1)),
          ],
        ),
        const SizedBox(height: 20),
        const Text('NO BROKERAGE FOR TENANTS', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.6)),
      ],
    );
  }
}

class HouseLogoPainter extends CustomPainter {
  const HouseLogoPainter({required this.strokeColor});

  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final roof =
        Path()
          ..moveTo(size.width * 0.13, size.height * 0.62)
          ..lineTo(size.width * 0.5, size.height * 0.22)
          ..lineTo(size.width * 0.87, size.height * 0.62);

    final body =
        Path()
          ..moveTo(size.width * 0.25, size.height * 0.62)
          ..lineTo(size.width * 0.25, size.height * 0.84)
          ..lineTo(size.width * 0.75, size.height * 0.84)
          ..lineTo(size.width * 0.75, size.height * 0.62)
          ..moveTo(size.width * 0.38, size.height * 0.62)
          ..lineTo(size.width * 0.38, size.height * 0.84)
          ..moveTo(size.width * 0.62, size.height * 0.62)
          ..lineTo(size.width * 0.62, size.height * 0.84);

    canvas.drawPath(roof, paint);
    canvas.drawPath(body, paint);

    final accent =
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.18, size.height * 0.66, size.width * 0.64, 4), const Radius.circular(2)), accent);
  }

  @override
  bool shouldRepaint(covariant HouseLogoPainter oldDelegate) => oldDelegate.strokeColor != strokeColor;
}

class SkylinePainter extends CustomPainter {
  const SkylinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFE9E4D8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final buildingPaint =
        Paint()
          ..color = const Color(0xFFE9E4D8).withValues(alpha: 0.55)
          ..style = PaintingStyle.fill;

    const buildings = [
      Rect.fromLTWH(0, 68, 26, 54),
      Rect.fromLTWH(28, 46, 42, 76),
      Rect.fromLTWH(72, 56, 30, 66),
      Rect.fromLTWH(106, 38, 36, 84),
      Rect.fromLTWH(146, 52, 32, 70),
      Rect.fromLTWH(182, 44, 30, 78),
      Rect.fromLTWH(214, 60, 34, 62),
      Rect.fromLTWH(252, 34, 34, 88),
      Rect.fromLTWH(290, 52, 30, 70),
    ];

    for (final rect in buildings) {
      canvas.drawRect(rect, buildingPaint);
      canvas.drawRect(rect, paint);

      final windowRows = (rect.height / 16).floor();
      for (var row = 0; row < windowRows; row++) {
        for (var col = 0; col < 3; col++) {
          final winX = rect.left + 6 + (col * 10);
          final winY = rect.top + 12 + (row * 14);
          if (winX + 4 < rect.right - 4) {
            canvas.drawRect(Rect.fromLTWH(winX, winY, 4, 8), paint);
          }
        }
      }
    }

    final roofLine =
        Path()
          ..moveTo(0, 90)
          ..lineTo(size.width, 90);
    canvas.drawPath(roofLine, paint);
  }

  @override
  bool shouldRepaint(covariant SkylinePainter oldDelegate) => false;
}
