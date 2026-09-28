import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
 import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/otp/otp_screen.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart' show AppIcons;

class MyRegisterScreen extends StatefulWidget {
  final String role;

  const MyRegisterScreen({super.key, this.role = 'user'});

  @override
  State<MyRegisterScreen> createState() => _MyRegisterScreenState();
}

class _MyRegisterScreenState extends State<MyRegisterScreen>
    with TickerProviderStateMixin {
  final _fomrkey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = false;
  String? _assignedBrokerId;
  List<Map<String, dynamic>> _brokers = [];

  late AnimationController _floatController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    if (widget.role == 'user') _loadBrokers();
  }

  Future<void> _loadBrokers() async {
    try {
      final brokers = await Authapi.getBrokerOptions(context: context);
      if (mounted) setState(() => _brokers = brokers);
    } catch (error) {
      debugPrint('Broker options load failed: $error');
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  _registerApi() async {
    // if (widget.role == 'user' && _assignedBrokerId == null) {
    //   Fluttertoast.showToast(msg: 'Please select a broker');
    //   return;
    // }
    await Authapi.register(
          data: {
            "fullName": _fullNameController.text.toString(),
            "mobileNo": int.tryParse(_mobileController.text),
            "email": _emailController.text.toString(),
            "address": _addressController.text.toString(),
            "password": _passwordController.text.toString(),
            "role": widget.role,
            if (widget.role == 'user') "assignedBroker": _assignedBrokerId,
          },
          context: context,
        )
        .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            log("Api Success");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => MyOtpScreen(
                      mobileNumber: _mobileController.text.toString(),
                    ),
              ),
            );
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
            // ── Atmospheric background ──────────────────────────────────
            _buildBackground(),

            // ── Content ────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            _buildWelcomeText(),
                            const SizedBox(height: 28),
                            _buildFormCard(),
                            const SizedBox(height: 28),
                            _buildSignInRow(),
                            const SizedBox(height: 36),
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

  // ── BACKGROUND ─────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF1A3E39), Color(0xFF265953), Color(0xFF1C4540)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Top-left golden orb
        Positioned(
          top: -100,
          left: -80,
          child: AnimatedBuilder(
            animation: _floatController,
            builder:
                (_, __) => Transform.translate(
                  offset: Offset(
                    8 * math.sin(_floatController.value * math.pi),
                    12 * math.cos(_floatController.value * math.pi),
                  ),
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
        ),

        // Bottom-right orb
        Positioned(
          bottom: -60,
          right: -60,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder:
                (_, __) => Transform.scale(
                  scale: 0.92 + 0.08 * _pulseController.value,
                  child: Container(
                    width: 200,
                    height: 200,
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
          ),
        ),

        // Subtle mid-screen accent line
        Positioned(
          top: 155,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withOpacity(0.0),
                  AppColors.secondary.withOpacity(0.10),
                  AppColors.secondary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── HEADER ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 8, left: 8, right: 16),
      child: Row(
        children: [
          // Back button
          GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              )
              .animate()
              .fade(duration: 500.ms)
              .slideX(begin: -0.3, curve: Curves.easeOut),

          // Logo centered
          Expanded(
                child: Center(
                  child: Image.asset(
                    AppIcons.icApp,
                    height: 48,
                    width: 140,
                    fit: BoxFit.contain,
                  ),
                ),
              )
              .animate()
              .fade(duration: 700.ms)
              .slideY(begin: -0.3, curve: Curves.easeOut),

          // Spacer to balance the back button
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ── WELCOME TEXT ───────────────────────────────────────────────────────────
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary.withOpacity(0.85),
                    letterSpacing: 3.0,
                  ),
                ),
              ],
            )
            .animate(delay: 150.ms)
            .fade(duration: 600.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),

        const SizedBox(height: 10),

        Text(
              'Join us &\nfind your home',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.18,
                letterSpacing: -0.5,
              ),
            )
            .animate(delay: 250.ms)
            .fade(duration: 600.ms)
            .slideX(begin: -0.2, curve: Curves.easeOut),
      ],
    );
  }

  // ── MAIN FORM CARD ─────────────────────────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 48,
            spreadRadius: 0,
            offset: const Offset(0, 24),
          ),
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.07),
            blurRadius: 16,
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
              // Gold → teal accent bar
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                ),
              ),

              // ── Step indicator ────────────────────────────────────
              _buildStepIndicator(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Section: Personal Info ─────────────────────
                    _buildSectionLabel(
                      icon: Icons.person_outline_rounded,
                      label: 'Personal Information',
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Full Name'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                      icon: Icons.badge_outlined,
                      validation: (v) => v!.validateFullName(context),
                    ),

                    const SizedBox(height: 18),
                    _buildInputLabel('Mobile Number'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _mobileController,
                      hint: 'Enter your mobile number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [LengthLimitingTextInputFormatter(10)],
                      validation: (v) => v!.validateMobileNumber(context),
                    ),

                    const SizedBox(height: 18),
                    _buildInputLabel('Email Address'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _emailController,
                      hint: 'Enter your email address',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validation: (v) => v!.validateEmail(context),
                    ),

                    const SizedBox(height: 18),
                    _buildInputLabel('Address'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _addressController,
                      hint: 'Street, city, area',
                      icon: Icons.location_on_outlined,
                      maxLines: 3,
                      validation: (v) => v!.validateRequireField(context),
                    ),

                    // const SizedBox(height: 18),
                    // if (widget.role == 'user') _buildInputLabel('Select Broker'),
                    // const SizedBox(height: 7),
                    // if (widget.role == 'user') Container(
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withValues(alpha: .08),
                    //     borderRadius: BorderRadius.circular(14),
                    //     border: Border.all(color: Colors.white24),
                    //   ),
                    //   padding: const EdgeInsets.symmetric(horizontal: 14),
                    //   child: DropdownButtonHideUnderline(
                    //     child: DropdownButton<String>(
                    //       value: _assignedBrokerId,
                    //       isExpanded: true,
                    //       hint: const Text('Choose your broker', style: TextStyle(color: Colors.white70)),
                    //       dropdownColor: AppColors.primary,
                    //       iconEnabledColor: Colors.white,
                    //       style: const TextStyle(color: Colors.white),
                    //       items: _brokers.map((broker) {
                    //         final id = broker['_id']?.toString();
                    //         final name = broker['fullName']?.toString() ?? 'Broker';
                    //         return DropdownMenuItem<String>(value: id, child: Text(name));
                    //       }).where((item) => item.value != null).toList(),
                    //       onChanged: (value) => setState(() => _assignedBrokerId = value),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 28),

                    // Divider with section label
                    _buildDividerWithLabel(),

                    const SizedBox(height: 24),

                    // ─── Section: Security ──────────────────────────
                    _buildSectionLabel(
                      icon: Icons.shield_outlined,
                      label: 'Security',
                    ),
                    const SizedBox(height: 16),

                    _buildInputLabel('Password'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _passwordController,
                      hint: 'Create a strong password',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscureText,
                      isPassword: true,
                      errorMaxLine: 2,
                      suffixIcon:
                          _obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                      onSuffixTap: _togglePassword,
                      validation: (v) => v?.validatePassword(context),
                    ),

                    const SizedBox(height: 18),
                    _buildInputLabel('Confirm Password'),
                    const SizedBox(height: 7),
                    _buildPremiumTextField(
                      controller: _confirmPasswordController,
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      isPassword: false,
                      errorMaxLine: 2,
                      validation: (v) => v?.validatePassword(context),
                    ),

                    const SizedBox(height: 30),

                    // Sign Up button
                    _buildSignUpButton(),
                  ],
                ),
              ),

              // ── Bottom OR divider ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: AppColors.bordercolor),
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
                      child: Container(height: 1, color: AppColors.bordercolor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ).animate(delay: 400.ms).fade(duration: 700.ms).slideY(begin: 0.12, curve: Curves.easeOut);
  }

  // ── STEP INDICATOR ─────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.lightgreen.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.bordercolor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildStepDot(step: '1', label: 'Details', isActive: true),
          _buildStepLine(isActive: false),
          _buildStepDot(step: '2', label: 'Verify OTP', isActive: false),
          _buildStepLine(isActive: false),
          _buildStepDot(step: '3', label: 'Done', isActive: false),
        ],
      ),
    );
  }

  Widget _buildStepDot({
    required String step,
    required String label,
    required bool isActive,
  }) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.bordercolor,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.secondary : AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.primary : AppColors.darkgreycolor,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isActive
                    ? [AppColors.primary, AppColors.secondary]
                    : [AppColors.bordercolor, AppColors.bordercolor],
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ──────────────────────────────────────────────────────────
  Widget _buildSectionLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkblack,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerWithLabel() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.bordercolor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Security Setup',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.darkgreycolor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.bordercolor)),
      ],
    );
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
    int maxLines = 1,
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
      maxLines: obscure ? 1 : maxLines,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: AppColors.darkblack,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13.5,
          color: AppColors.bordercolor,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 46,
        ),
        suffixIcon:
            isPassword
                ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      suffixIcon,
                      size: 19,
                      color: AppColors.darkgreycolor,
                    ),
                  ),
                )
                : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 46,
          minHeight: 46,
        ),
        filled: true,
        fillColor: AppColors.thirdwhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
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

  // ── SIGN UP BUTTON ─────────────────────────────────────────────────────────
  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: () async {
          if (_passwordController.text == _confirmPasswordController.text) {
            if (_fomrkey.currentState!.validate()) {
              await _registerApi();
            }
          } else {
            Fluttertoast.showToast(
              msg: 'Password and Confirm password must be same',
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.secondary,
                Color(0xffA8895E),
                AppColors.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.38),
                blurRadius: 18,
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
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── SIGN IN ROW ────────────────────────────────────────────────────────────
  Widget _buildSignInRow() {
    return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.white.withOpacity(0.65),
                fontWeight: FontWeight.w400,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
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
                  'Sign In',
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
        .animate(delay: 700.ms)
        .fade(duration: 600.ms)
        .slideY(begin: 0.2, curve: Curves.easeOut);
  }
}
