import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';

class MyCustomHeaderLogo extends StatelessWidget {
  const MyCustomHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Container(
      color: AppColors.primary,
      width: screenSize!.width,
      child: IconButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {},
        icon: Center(
          child: Image.asset(
            AppIcons.icApp,
            height: 50,
            width: 100,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
