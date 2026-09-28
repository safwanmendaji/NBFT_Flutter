import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';

Widget getTextWidget(
        {required String title,
        Color textColor = AppColors.primary,
        double textFontSize = AppFonts.size14,
        double? letterSpacing,
        FontWeight? textFontWeight = AppFonts.regular,
        TextAlign? textAlign,
        TextDecoration? textDecoration,
        FontStyle? textFontStyle,
        TextDirection? textDirection,
        String? fontFamily = 'Poppins',
        double? height,
        int? maxLines}) =>
    Text(title,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
        textDirection: textDirection,
        style: TextStyle(
            height: height,
            fontSize: textFontSize,
            color: textColor,
            fontFamily: fontFamily,
            letterSpacing: letterSpacing,
            decoration: textDecoration,
            fontWeight: textFontWeight,
            fontStyle: textFontStyle));
