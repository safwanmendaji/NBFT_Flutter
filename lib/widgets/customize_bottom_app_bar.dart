  import 'package:flutter/material.dart';
   import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
   import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

   import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';

  bottomTabItem({
    required String icon,
    required String sicon,
    required BuildContext context,
    required String title,
    required int tabValue,
    required int curValue,
    required Function iconAction,
  }) =>
      GestureDetector(
        onTap: () {
          iconAction();
        },
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              // margin: const EdgeInsets.only(top: 20.0),
              decoration: BoxDecoration(
                  color:
                      tabValue == curValue ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Center(
                child: Image.asset(
                  tabValue == curValue ? sicon : icon,
                  height: 24,
                  width: 24,
                  // color: tabValue == curValue
                  //     ? AppColors.secondary
                  //     : Theme.of(context).textTheme.displayMedium!.color,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            getTextWidget(
              title: title,
              textFontSize: AppFonts.size12,
              textFontWeight: AppFonts.semiBold,
              textColor:
                  tabValue == curValue ? AppColors.primary : AppColors.blackColor,
            )
          ],
        ),
      );
