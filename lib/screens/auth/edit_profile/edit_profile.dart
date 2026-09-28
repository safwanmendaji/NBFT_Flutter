import 'dart:developer';

import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
 import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
import 'package:fluttertoast/fluttertoast.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyEditProfile extends StatefulWidget {
  const MyEditProfile({super.key});

  @override
  State<MyEditProfile> createState() => _MyEditProfileState();
}

class _MyEditProfileState extends State<MyEditProfile> {
  final _fomrkey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  _editprofileApi() async {
    await Authapi.editprofile(data: {
      "fullName": _fullNameController.text.toString(),
      "address": _addressController.text.toString(),
    }, context: context, id: Prefs.getString(LocalStrings.userid))
        .then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Api Success");
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Profile Updated Successfully');
      } else {
        log("Api failed");
        customizedAlertDialogue(
            context: context,
            desc: "${response.message}",
            onPressed: () {
              Navigator.pop(context);
            }).show();
      }
    }).catchError((error) {
      ErrorManager().showErrorDialogue(e: error, context: context);
    }).onError((error, stacktrace) {
      ErrorManager().showErrorDialogue(e: error, context: context);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _fullNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fullNameController.text = Prefs.getString(LocalStrings.username);
    _addressController.text = Prefs.getString(LocalStrings.useraddress);
    _emailController.text = Prefs.getString(LocalStrings.useremail);
    _mobileController.text = Prefs.getString(LocalStrings.usernumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            title: "Edit Profile",
            isBackButton: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getImage(),
                    _getRegistrationForm(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            bottom: 16.0, left: 20.0, right: 20.0, top: 10.0),
        child: Container(
          child: _getButton(),
        ),
      ),
    );
  }

  _getButton() => CustomizedButton(
        onTap: () async {
          if (_fomrkey.currentState!.validate()) {
            await _editprofileApi();
          }
        },
        title: 'Update Profile',
      );

  _getRegistrationForm() => Padding(
        padding: const EdgeInsets.only(right: 30.0),
        child: Form(
          key: _fomrkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTextWidget(
                  title: 'Full Name',
                  textFontSize: AppFonts.size18,
                  textFontWeight: AppFonts.semiBold,
                  textColor: AppColors.white),
              PrimaryTextFeild(
                controller: _fullNameController,
                hintText: 'Full Name',
                validation: (value) => value!.validateFullName(context),
              ),
              const SizedBox(
                height: 8.0,
              ),
              getTextWidget(
                  title: 'Contacr Number',
                  textFontSize: AppFonts.size18,
                  textFontWeight: AppFonts.semiBold,
                  textColor: AppColors.white),
              PrimaryTextFeild(
                controller: _mobileController,
                hintText: 'Mobile Number',
                // prefixIcon: AppIcons.ic91,
                readonly: true,
                keyboardType: TextInputType.number,
                validation: (value) => value!.validateMobileNumber(context),
              ),
              const SizedBox(
                height: 8.0,
              ),
              getTextWidget(
                  title: 'Email',
                  textFontSize: AppFonts.size18,
                  textFontWeight: AppFonts.semiBold,
                  textColor: AppColors.white),
              PrimaryTextFeild(
                controller: _emailController,
                hintText: 'Email',
                readonly: true,
                keyboardType: TextInputType.emailAddress,
                validation: (value) => value!.validateEmail(context),
              ),
              const SizedBox(
                height: 8.0,
              ),
              getTextWidget(
                  title: 'Address',
                  textFontSize: AppFonts.size18,
                  textFontWeight: AppFonts.semiBold,
                  textColor: AppColors.white),
              PrimaryTextFeild(
                controller: _addressController,
                hintText: 'abcd street, ahmedabad',
                maxline: 5,
                validation: (value) => value!.validateRequireField(context),
              ),
            ],
          ),
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

  _getCurrentDay() => Padding(
        padding: const EdgeInsets.only(top: 1.0),
        child: getTextWidget(
          title: getFormattedDate(),
          textFontSize: AppFonts.size16,
          textColor: AppColors.daycolor,
        ),
      );
}
