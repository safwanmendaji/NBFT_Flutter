import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyChangePassword extends StatefulWidget {
  const MyChangePassword({super.key});

  @override
  State<MyChangePassword> createState() => _MyChangePasswordState();
}

class _MyChangePasswordState extends State<MyChangePassword> {
  final _oldPassworld = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            isBackButton: true,

            title: "Change Password",
            // isBacButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, top: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Image.asset(
                    //     AppIcons.icSemiCircle,
                    //     height: 110,
                    //   ),
                    // ),

                    _getForm(),
                    _getButton()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getButton() => Padding(
        padding: const EdgeInsets.only(
          top: 27.0,
          right: 30.0,
        ),
        child: CustomizedButton(
          onTap: () {},
          title: 'Change Password',
        ),
      );

  _getForm() => Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTextWidget(
                title: 'Old Password',
                textFontSize: AppFonts.size18,
                textFontWeight: AppFonts.semiBold,
                textColor: AppColors.white),
            PrimaryTextFeild(
              controller: _oldPassworld,
              obscure: true,
              errorMaxline: 2,
              hintText: 'Old Password',
              validation: (value) => value?.validatePassword(context),
            ),
            const SizedBox(
              height: 13.0,
            ),
            getTextWidget(
                title: 'New Password',
                textFontSize: AppFonts.size18,
                textFontWeight: AppFonts.semiBold,
                textColor: AppColors.white),
            PrimaryTextFeild(
              controller: _newPassword,
              obscure: true,
              errorMaxline: 2,
              hintText: 'New Password',
              validation: (value) => value?.validatePassword(context),
            ),
            const SizedBox(
              height: 13.0,
            ),
            getTextWidget(
                title: 'Confirm Password',
                textFontSize: AppFonts.size18,
                textFontWeight: AppFonts.semiBold,
                textColor: AppColors.white),
            PrimaryTextFeild(
              controller: _confirmPassword,
              obscure: true,
              errorMaxline: 2,
              hintText: 'Confirm Password',
              validation: (value) => value?.validatePassword(context),
            ),
          ],
        ),
      );

  _getCurrentDay() => Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: getTextWidget(
          title: getFormattedDate(),
          textFontSize: AppFonts.size16,
          textColor: AppColors.daycolor,
        ),
      );
}
