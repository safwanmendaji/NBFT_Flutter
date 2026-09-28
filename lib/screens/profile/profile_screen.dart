import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/dialogue.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/account/account.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/change_password/change_password.dart';
 import 'package:flutter_nobrokeragefortenants/screens/auth/edit_profile/edit_profile.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_profile_option.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';

class MyProfile extends StatefulWidget {
  final bool hideTopHeaders;

  const MyProfile({super.key, this.hideTopHeaders = false});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  List profileOption = [
    {
      'name': 'Change Password',
      'icon': AppIcons.icLock,
      'height': 26.0,
      'widht': 20.0,
      'route': const MyChangePassword(),
    },
    {
      'name': 'Account',
      'height': 19.0,
      'widht': 19.0,
      'icon': AppIcons.icUser,
      'route': const MyAccount(),
    },
    // {
    //   'name': 'Properties',
    //   'height': 18.0,
    //   'widht': 21.0,
    //   'icon': AppIcons.icPrimaryProperties,
    //   'route': null,
    // },
    {
      'name': 'Edit Profile',
      'height': 22.0,
      'widht': 22.0,
      'icon': AppIcons.icEditProfile,
      'route': const MyEditProfile(),
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!widget.hideTopHeaders) ...[
            const MyCustomHeaderLogo(),
            const MyCustomHeader(title: "Settings"),
          ],
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 30.0, top: 20.0),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _getHeader(),

                    // _getCurrentDay(),
                    _getProfileoption(),
                    const Padding(
                      padding: EdgeInsets.only(right: 33.0, top: 30),
                      child: Divider(color: Color(0XFFCFCFCF), height: 1),
                    ),
                    _getLogout(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _getLogout() => Padding(
    padding: const EdgeInsets.only(top: 27.0, left: 10.0),
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showLogoutDialog(context);
      },
      child: Row(
        children: [
          Image.asset(
            AppIcons.icLogout,
            height: 22,
            width: 22,
            color: AppColors.white,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16.0),
          getTextWidget(
            title: 'Log Out',
            textFontSize: AppFonts.size18,
            textColor: AppColors.white,
          ),
        ],
      ),
    ),
  );

  _getProfileoption() => Padding(
    padding: const EdgeInsets.only(left: 10.0, top: 30.0, right: 31.0),
    child: ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: profileOption.length,
      itemBuilder: (context, index) {
        return MyProfileOption(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => profileOption[index]['route'],
              ),
            );
          },
          height: profileOption[index]['height'],
          width: profileOption[index]['width'],
          icon: profileOption[index]['icon'],
          name: profileOption[index]['name'],
        );
      },
    ),
  );

  //    Row(
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: [
  //       Image.asset(
  //         AppIcons.icLock,
  //         width: 20,
  //         height: 26,
  //         fit: BoxFit.cover,
  //       ),
  //       SizedBox(
  //         width: 18.0,
  //       ),
  // getTextWidget(
  //   title: 'Change Password',
  //   textFontSize: AppFonts.size18,
  //   textColor: AppColors.profilecolor,
  // ),
  //       Spacer(),
  //       Image.asset(
  //         AppIcons.icArrowRight,
  //         height: 12.0,
  //         width: 12.0,
  //         fit: BoxFit.cover,
  //       )
  //     ],
  //   ),
  // );
}
