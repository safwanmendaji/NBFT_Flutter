import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyProfileOption extends StatefulWidget {
  final String? icon;
  final String? name;
  final double? height;
  final double? width;
  final void Function()? onTap;
  const MyProfileOption(
      {super.key,
      required this.icon,
      required this.name,
      this.onTap,
      this.height,
      this.width});

  @override
  State<MyProfileOption> createState() => _MyProfileOptionState();
}

class _MyProfileOptionState extends State<MyProfileOption> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Row(
          children: [
            Image.asset(
              widget.icon!,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
              color: AppColors.white,
            ),
            const SizedBox(
              width: 18.0,
            ),
            getTextWidget(
              title: widget.name!,
              textFontSize: AppFonts.size18,
              textColor: AppColors.white,
            ),
            const Spacer(),
            Image.asset(
              AppIcons.icArrowRight,
              height: 12.0,
              width: 12.0,
              color: AppColors.white,
              fit: BoxFit.cover,
            )
          ],
        ),
      ),
    );
  }
}
