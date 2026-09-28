import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';

class CustomizedButton extends StatelessWidget {
  final String title;
  final Color textColor;
  final Color buttonColor;
  final double height;
  final double radius;
  final double borderwidth;
  final Color bordercolor;
  final String fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final void Function()? onTap;

  const CustomizedButton({
    required this.title,
    this.fontSize = AppFonts.size15,
    this.fontWeight = AppFonts.bold,
    this.height = 45,
    this.radius = 15.0,
    this.textColor = AppColors.primary,
    this.buttonColor = AppColors.secondary,
    this.onTap,
    super.key,
    this.borderwidth = 0.0,
    this.bordercolor = Colors.transparent,
    this.fontFamily = 'Poppins',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: buttonColor,
          border: Border.all(width: borderwidth, color: bordercolor),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontFamily: fontFamily,
            fontSize: fontSize,
            fontWeight: fontWeight,
          ),
        ),
        // CustomizedText(
        //   title: title,
        //   textColor: textColor,
        //   textFontSize: fontSize,
        //   textFontWeight: fontWeight,
        //   textAlign: TextAlign.center,
        // ),
      ),
    );
  }
}
