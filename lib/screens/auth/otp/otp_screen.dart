import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/screens/auth/login/login_screen.dart';
import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyOtpScreen extends StatefulWidget {
  final String mobileNumber;

  const MyOtpScreen({super.key, required this.mobileNumber});

  @override
  State<MyOtpScreen> createState() => _MyOtpScreenState();
}

class _MyOtpScreenState extends State<MyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final _formkey = GlobalKey<FormState>();

  _verifyOtpApi() async {
    await Authapi.otpverify(data: {"mobileNo": widget.mobileNumber.toString(), "otp": _otpController.text.toString()}, context: context)
        .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            log("Api Success");
            Fluttertoast.showToast(msg: 'Otp Verify Successfully');
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MyLoginScreen()), (route) => false);
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
          // showerrorManage(e: error);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);

          // showerrorManage(e: error);
        });
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Container(
      height: screenSize!.height,
      width: screenSize!.width,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/bg.jpeg"), fit: BoxFit.cover)),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 100),
              width: screenSize!.width,
              //decoration: BoxDecoration(color: AppColors.primary),
              child: IconButton(onPressed: () {}, icon: Image.asset(AppIcons.icApp, height: 90, width: 200, fit: BoxFit.cover, color: AppColors.white)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: .0, left: 37.0, right: 36.0, bottom: 50.0),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: screenSize!.width - 90,
                    height: 400,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(43)),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: screenSize!.width,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              color: AppColors.white,
                              // gradient: LinearGradient(
                              //   colors: [Color(0xffBFA380), Color(0xff594C3C)],
                              // ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: getTextWidget(title: "Otp Verify", textAlign: TextAlign.center, textFontSize: AppFonts.size30, textColor: AppColors.primary, textFontWeight: AppFonts.semiBold),
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(top: 17.0, right: 9.0, left: 10.0),
                            child: getTextWidget(textAlign: TextAlign.center, textColor: AppColors.white, title: 'Enter the OTP sent to your whatsapp!', textFontWeight: AppFonts.semiBold),
                          ),
                          SizedBox(height: 20),
                          _getOtpFeild(),
                          SizedBox(height: 20),

                          _getNumber(),
                          SizedBox(height: 20),
                          _getButton(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getButton() => Padding(
    padding: const EdgeInsets.only(left: 22.0, right: 30.0, top: 13.0, bottom: 24.0),
    child: CustomizedButton(
      onTap: () async {
        if (_formkey.currentState!.validate()) {
          await _verifyOtpApi();
        }
      },
      title: 'Verify OTP',
      buttonColor: AppColors.white,
    ),
  );

  _getNumber() => Column(
    children: [
      getTextWidget(title: 'OTP sent to whatsapp on :', textFontSize: AppFonts.size15, textFontWeight: AppFonts.medium, textColor: AppColors.white),
      getTextWidget(title: '+91 09873 17338', textFontSize: AppFonts.size15, textFontWeight: AppFonts.medium, textColor: AppColors.white),
    ],
  );

  _getOtpFeild() => SizedBox(
    child: Padding(
      padding: const EdgeInsets.only(top: 21.0, left: 34.0, right: 43.0),
      child: Form(
        key: _formkey,
        child: PinCodeTextField(
          enableActiveFill: true,
          cursorColor: AppColors.primary,
          keyboardType: TextInputType.number,
          autoFocus: true,
          controller: _otpController,
          validator: (value) => value?.validateRequireField(context),
          textStyle: const TextStyle(color: AppColors.primary, fontFamily: 'Poppins', fontSize: AppFonts.size20, fontWeight: AppFonts.semiBold),
          onChanged: (value) {
            setState(() {
              _otpController.text = value;
            });
          },
          appContext: context,
          length: 4,
          pinTheme: PinTheme(
            borderRadius: BorderRadius.circular(17.0),
            shape: PinCodeFieldShape.box,
            fieldHeight: 45,
            fieldWidth: 45,
            borderWidth: 2.0,
            activeFillColor: AppColors.white,
            inactiveFillColor: AppColors.white,
            selectedFillColor: AppColors.white,
            selectedColor: AppColors.greyColor,
            activeColor: AppColors.primary,
          ),
        ),
      ),
    ),
  );
}
