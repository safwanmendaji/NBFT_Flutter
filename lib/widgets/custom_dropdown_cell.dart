import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyCustomizeDropdown extends StatefulWidget {
  final String? labelText;
  final List<String>? items;
  final String? selectedValue;
  final String selecttext;
  final Color fontColor;
  final double fontsize;
  final double hintfontsize;
  final double buttonheight;
  final FontWeight fontwieght;
  final Function(dynamic)? onChanged;
  final double? dropdownwidth;
  const MyCustomizeDropdown({
    super.key,
    this.items,
    this.hintfontsize = AppFonts.size14,
    this.buttonheight = 45.0,
    this.fontColor = AppColors.blackColor,
    this.fontsize = AppFonts.size14,
    this.selecttext = 'Select',
    this.fontwieght = AppFonts.regular,
    this.dropdownwidth,
    this.labelText,
    this.onChanged,
    this.selectedValue,
  });

  @override
  State<MyCustomizeDropdown> createState() => _MyCustomizeDropdownState();
}

class _MyCustomizeDropdownState extends State<MyCustomizeDropdown> {
  late final ValueNotifier<String?> _valueNotifier =
  ValueNotifier<String?>(widget.selectedValue);

  @override
  void didUpdateWidget(covariant MyCustomizeDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the notifier in sync if the parent passes a new selectedValue.
    if (widget.selectedValue != oldWidget.selectedValue &&
        widget.selectedValue != _valueNotifier.value) {
      _valueNotifier.value = widget.selectedValue;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: widget.labelText!,
          textFontSize: widget.fontsize,
          textFontWeight: widget.fontwieght,
          textColor: widget.fontColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              style: const TextStyle(color: AppColors.primary),
              isExpanded: true,
              hint: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: getTextWidget(
                      title: widget.selecttext,
                      textColor: AppColors.blackColor,
                      textFontSize: widget.hintfontsize,
                      textFontWeight: AppFonts.regular,
                    ),
                  ),
                ],
              ),
              items:
              widget.items!.map((item) {
                return DropdownItem<String>(
                  value: item,
                  enabled: true,
                  height: 40,
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Flexible(
                          child: getTextWidget(
                            maxLines: 1,
                            title: item.toString(),
                            textColor: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              valueListenable: _valueNotifier,
              onChanged: (value) {
                _valueNotifier.value = value;
                widget.onChanged?.call(value);
              },
              buttonStyleData: ButtonStyleData(
                height: widget.buttonheight,
                width: screenSize!.width,
                padding: const EdgeInsets.only(left: 14, right: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: AppColors.primary, width: 2.0),
                  color: AppColors.white,
                ),
              ),
              iconStyleData: IconStyleData(
                icon: Image.asset(
                  AppIcons.icGreenArrowDown,
                  height: 12,
                  width: 12,
                  // color: AppColors.blackColor,
                  fit: BoxFit.cover,
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 200,
                width: widget.dropdownwidth,
                padding: null,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
                scrollbarTheme: ScrollbarThemeData(
                  radius: const Radius.circular(6),
                  thickness: WidgetStateProperty.all<double>(6),
                  thumbVisibility: WidgetStateProperty.all<bool>(true),
                ),
              ),
              menuItemStyleData: const MenuItemStyleData(
                padding: EdgeInsets.only(left: 14, right: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}