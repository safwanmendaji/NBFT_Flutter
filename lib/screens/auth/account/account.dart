import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            title: "Account",
            isBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 30.0, bottom: 50.0, top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_getImage(), _getName(), _getInformation()],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getInformation() => Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Image.asset(
                    AppIcons.icPrimaryUser,
                    height: 42,
                    width: 42,
                    color: AppColors.white,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(
                    width: 15.0,
                  ),
                  getTextWidget(
                      title: 'Contact Number',
                      textFontSize: AppFonts.size16,
                      textFontWeight: AppFonts.medium,
                      textColor: AppColors.white),
                  const Spacer(),
                  getTextWidget(
                      title: Prefs.getString(LocalStrings.usernumber),
                      textFontSize: AppFonts.size15,
                      textFontWeight: AppFonts.semiBold,
                      textColor: AppColors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3.0, top: 25, right: 16.0),
              child: Row(
                children: [
                  Image.asset(
                    AppIcons.icPrimaryEmail,
                    height: 34,
                    width: 34,
                    fit: BoxFit.cover,
                    color: AppColors.white,
                  ),
                  const SizedBox(
                    width: 18.0,
                  ),
                  getTextWidget(
                    title: 'Email',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.medium,
                    textColor: AppColors.white,
                  ),
                  const Spacer(),
                  getTextWidget(
                      title: Prefs.getString(LocalStrings.useremail),
                      textFontSize: AppFonts.size15,
                      maxLines: 2,
                      textFontWeight: AppFonts.semiBold,
                      textColor: AppColors.white),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25.0, left: 5, right: 16.0),
              child: SizedBox(
                child: Row(
                  children: [
                    Image.asset(
                      AppIcons.icPrimaryMarker,
                      height: 30,
                      width: 30,
                      color: AppColors.white,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 18.0,
                    ),
                    getTextWidget(
                        title: 'Address',
                        textFontSize: AppFonts.size15,
                        textFontWeight: AppFonts.medium,
                        textColor: AppColors.white),
                    const Spacer(),
                    getTextWidget(
                        title: Prefs.getString(LocalStrings.useraddress),
                        textFontSize: AppFonts.size15,
                        maxLines: 2,
                        textFontWeight: AppFonts.semiBold,
                        textColor: AppColors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  _getName() => Center(
        child: getTextWidget(
          title: Prefs.getString(LocalStrings.username),
          textFontSize: AppFonts.size24,
          textFontWeight: AppFonts.bold,
          textColor: AppColors.white,
        ),
      );

  _getImage() => Padding(
        padding: const EdgeInsets.only(top: 21.0),
        child: Center(
          child: ClipOval(
            child: Image.asset(
              AppIcons.icUserImage,
              height: 178,
              width: 178,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
}
