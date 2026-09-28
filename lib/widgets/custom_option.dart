import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class OptionSelector extends StatelessWidget {
  final List options;
  final int? selectedIndex;
  final Function(int) onTap;

  const OptionSelector({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: List.generate(options.length, (index) {
        final isSelected = selectedIndex == index;
        return Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
          child: GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.lightgreen : AppColors.secondwhite,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.bordercolor,
                  width: 1,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11.0, vertical: 1.0),
                child: getTextWidget(
                  title: options[index],
                  textFontSize: AppFonts.size12,
                  textColor:
                      isSelected ? AppColors.primary : AppColors.bordercolor,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
