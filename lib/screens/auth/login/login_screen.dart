import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/register/register_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/register/account_type_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/user/subscription_screen.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_bottom_tab.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
import 'package:flutter_nobrokeragefortenants/services/subscription_gate.dart';

class MyLoginScreen extends StatefulWidget {
  const MyLoginScreen({super.key});

  @override
  State<MyLoginScreen> createState() => _MyLoginScreenState();
}

class _MyLoginScreenState extends State<MyLoginScreen>
    with TickerProviderStateMixin {
  final _fomrkey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = false;

  late AnimationController _shimmerController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _floatController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _loginApi() async {
    await Authapi.login(
          data: {
            "mobileNo": _mobileController.text.toString(),
            "password": _passwordController.text.toString(),
          },
          context: context,
        )
        .then((response) async {
          if (response.statusCode == 200 || response.statusCode == 201) {
            log("Api Success");
            Fluttertoast.showToast(msg: 'Login Successfully ');
            await Prefs.setString(
              LocalStrings.usertoken,
              response.data!.token!,
            );
            await Prefs.setString(
              LocalStrings.username,
              response.data!.user!.fullName!,
            );
            await Prefs.setString(
              LocalStrings.userid,
              response.data!.user!.sId!,
            );
            await Prefs.setString(
              LocalStrings.usernumber,
              response.data!.user!.mobileNo!,
            );
            await Prefs.setString(
              LocalStrings.useremail,
              response.data!.user!.email!,
            );
            await Prefs.setString(
              LocalStrings.useraddress,
              response.data!.user!.address!,
            );
            await Prefs.setString(
              LocalStrings.userrole,
              response.data!.user!.role ?? 'broker',
            );
            await Prefs.setString(LocalStrings.userstatus, "1");
            await Prefs.setBool(
              LocalStrings.subscribedCommercial,
              response.data!.user!.isSubscribedForCommercial == true,
            );
            await Prefs.setBool(
              LocalStrings.subscribedResidential,
              response.data!.user!.isSubscribedForResidential == true,
            );
            setState(() {});
            final role = (response.data!.user!.role ?? 'broker').toLowerCase();
            final isUser = role == 'user' || role == 'tenant';
            final hasSubscription =
                isUser
                    ? (await SubscriptionGate.refresh(context))?.isActive ==
                            true ||
                        response.data!.user!.isSubscribedForCommercial ==
                            true ||
                        response.data!.user!.isSubscribedForResidential == true
                    : true;
            print("isUser: $isUser");
            print("hasSubscription: $hasSubscription");
            print(
              "Navigate to: ${isUser && !hasSubscription ? "SubscriptionScreen" : "PrimaryBottomTab"}",
            );

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        isUser && !hasSubscription
                            ? const SubscriptionScreen()
                            : const PrimaryBottomTab(),
              ),
              (_) => false,
            );
          } else if (response.statusCode == 404) {
            log("Api failed");
            log("${response.statusCode}");
            customizedAlertDialogue(
              context: context,
              desc: "${response.message}",
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          } else {
            log("Api failed");
            customizedAlertDialogue(
              context: context,
              desc: "${response.message}",
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Stack(
          children: [
            // ── Atmospheric background ──────────────────────────────────────
            _buildBackground(),

            // ── Main scrollable content ─────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            _buildWelcomeText(),
                            const SizedBox(height: 32),
                            _buildFormCard(),
                            const SizedBox(height: 28),
                            _buildSignUpRow(),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BACKGROUND with layered depth ─────────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3E39), Color(0xFF265953), Color(0xFF1E4A44)],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),

        // Top-right golden orb
        Positioned(
          top: -80,
          right: -60,
          child: AnimatedBuilder(
            animation: _floatController,
            builder:
                (_, __) => Transform.translate(
                  offset: Offset(
                    0,
                    10 * math.sin(_floatController.value * math.pi),
                  ),
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.18),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ),

        // Bottom-left subtle orb
        Positioned(
          bottom: 60,
          left: -80,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.10),
                  AppColors.secondary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Subtle geometric line accent
        Positioned(
          top: 160,
          left: 0,
          right: 0,
          child: CustomPaint(
            painter: _DiagonalAccentPainter(),
            child: const SizedBox(height: 2),
          ),
        ),
      ],
    );
  }

  // ── HEADER: Logo area ──────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: Column(
        children: [
          // Logo
          Image.asset(
                AppIcons.icApp,
                height: 56,
                width: 160,
                fit: BoxFit.contain,
              )
              .animate()
              .fade(duration: 800.ms)
              .slideY(begin: -0.3, curve: Curves.easeOut),

          const SizedBox(height: 12),

          // Thin golden divider
          Container(
                width: 48,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.0),
                      AppColors.secondary,
                      AppColors.secondary.withOpacity(0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              )
              .animate(delay: 300.ms)
              .fade(duration: 600.ms)
              .scaleX(begin: 0, curve: Curves.easeOut),
        ],
      ),
    );
  }

  // ── WELCOME TEXT ───────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Welcome Back" label
        Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary.withOpacity(0.85),
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            )
            .animate(delay: 200.ms)
            .fade(duration: 700.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),

        const SizedBox(height: 10),

        Text(
              'Sign in to your\naccount',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            )
            .animate(delay: 350.ms)
            .fade(duration: 700.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),
      ],
    );
  }

  // ── FORM CARD ──────────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 40,
                spreadRadius: 0,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Form(
              key: _fomrkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Card top accent bar
                  // Container(
                  //   height: 4,
                  //   decoration: const BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: [AppColors.primary, AppColors.secondary],
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mobile Number
                        _buildInputLabel('Mobile Number'),
                        const SizedBox(height: 8),
                        _buildPremiumTextField(
                          controller: _mobileController,
                          hint: 'Enter your mobile number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validation: (v) => v!.validateMobileNumber(context),
                        ),

                        const SizedBox(height: 22),

                        // Password
                        _buildInputLabel('Password'),
                        const SizedBox(height: 8),
                        _buildPremiumTextField(
                          controller: _passwordController,
                          hint: 'Enter your password',
                          icon: Icons.lock_outline_rounded,
                          obscure: _obscureText,
                          isPassword: true,
                          errorMaxLine: 2,
                          validation: (v) => v?.validatePassword(context),
                          onSuffixTap: _togglePassword,
                          suffixIcon:
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                        ),

                        const SizedBox(height: 14),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // Sign In button
                        _buildSignInButton(),
                      ],
                    ),
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.bordercolor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'OR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkgreycolor,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: AppColors.bordercolor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // OR section padding
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        )
        .animate(delay: 500.ms)
        .fade(duration: 700.ms)
        .slideY(begin: 0.15, curve: Curves.easeOut);
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkblack,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validation,
    bool obscure = false,
    bool isPassword = false,
    int errorMaxLine = 1,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validation,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.darkblack,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14,
          color: AppColors.bordercolor,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        suffixIcon:
            isPassword
                ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      suffixIcon,
                      size: 20,
                      color: AppColors.darkgreycolor,
                    ),
                  ),
                )
                : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        filled: true,
        fillColor: AppColors.thirdwhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.bordercolor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.bordercolor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        errorMaxLines: errorMaxLine,
        errorStyle: const TextStyle(fontSize: 11.5),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          if (_fomrkey.currentState!.validate()) {
            await _loginApi();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E4A44), AppColors.primary, Color(0xFF2F6B63)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.45),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SIGN UP ROW ────────────────────────────────────────────────────────────
  Widget _buildSignUpRow() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account?',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.white.withOpacity(0.65),
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountTypeScreen(),
                  ),
                ).then((value) {
                  setState(() {
                    _fomrkey.currentState!.reset();
                  });
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.secondary.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        )
        .animate(delay: 800.ms)
        .fade(duration: 600.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}

// ── Custom painter for diagonal accent line ────────────────────────────────
class _DiagonalAccentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.0),
              AppColors.secondary.withOpacity(0.12),
              AppColors.secondary.withOpacity(0.0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset.zero, Offset(size.width, 0), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
