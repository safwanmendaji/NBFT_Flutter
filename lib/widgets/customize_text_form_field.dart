import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';

class PrimaryTextFeild extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final String? prefixIcon, suffixIcon;
  final bool filled;
  final bool readonly;
  final FocusNode? focusNode;
  final double prefixHeight, prefixWidth, suffixHeight, suffixWidth;
  final AutovalidateMode autoValidate;
  final TextInputAction textInputAction;
  final String? Function(String?)? validation;
  final Color fillColor;
  final Color borderColor;
  final Color prefixiconcolor;
  final Color suffixiconcolor;
  final bool obscureText;
  final bool? obscure;
  final String? image;
  final int? maxline;
  final int? errorMaxline;
  final List<TextInputFormatter>? inputFormatters;
  final double borderradius;
  final bool enable;
  final Widget? suffix;
  final String? anysuffixicon;
  // final String suffixText;
  // final TextStyle? suffixtextstyle;
  final Function(void)? onfeildSubmitted;
  final Function()? onEditingComplete;
  final Function(String)? onChange;
  final void Function()? onSuffixTap;
  final Color hintColor;
  final Color textstyle;
  final bool autoFocus;
  final double fontSize;
  final FontWeight fontWeight;

  const PrimaryTextFeild(
      {super.key,
      this.suffix,
      this.suffixHeight = 24.0,
      this.suffixWidth = 24.0,
      this.prefixHeight = 24.0,
      this.prefixWidth = 24.0,
      this.borderradius = 15.0,
      this.controller,
      this.hintText,
      this.focusNode,
      this.onEditingComplete,
      this.textInputAction = TextInputAction.done,
      this.anysuffixicon = '',
      this.readonly = false,
      this.inputFormatters,
      this.obscure = false,
      this.keyboardType,
      this.errorMaxline,
      this.maxline = 1,
      this.onfeildSubmitted,
      this.autoValidate = AutovalidateMode.disabled,
      // this.suffixText = '',
      this.prefixIcon,
      this.autoFocus = false,
      // this.suffixtextstyle,
      this.suffixiconcolor = AppColors.blackColor,
      this.textstyle = AppColors.blackColor,
      this.prefixiconcolor = AppColors.blackColor,
      this.hintColor = AppColors.blackColor,
      this.onChange,
      this.onSuffixTap,
      // this.autoValidate = AutovalidateMode.onUserInteraction;
      this.fontSize = AppFonts.size14,
      this.fontWeight = AppFonts.regular,
      this.enable = true,
      this.filled = true,
      this.fillColor = Colors.white,
      this.borderColor = AppColors.primary,
      this.suffixIcon,
      this.validation,
      this.image,
      this.obscureText = false});

  @override
  State<PrimaryTextFeild> createState() => _PrimaryTextFeildState();
}

class _PrimaryTextFeildState extends State<PrimaryTextFeild> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      autovalidateMode: widget.autoValidate,
      textInputAction: widget.textInputAction,
      validator: widget.validation,
      controller: widget.controller,
      onEditingComplete: widget.onEditingComplete,
      readOnly: widget.readonly,
      onChanged: widget.onChange,
      autofocus: widget.autoFocus,
      maxLines: widget.maxline,
      focusNode: widget.focusNode,
      inputFormatters: widget.inputFormatters,
      onFieldSubmitted: widget.onfeildSubmitted,
      keyboardType: widget.keyboardType,

      // autofocus: true,

      obscureText: widget.obscureText ? widget.obscure! : false,
      style: TextStyle(
          color: widget.textstyle,
          fontFamily: 'Poppins',
          fontWeight: AppFonts.medium,
          fontSize: AppFonts.size14),
      decoration: InputDecoration(
        suffix: widget.suffix,
        contentPadding:
            const EdgeInsets.only(left: 16.0, right: 16.0, top: 13.0),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.hintColor,
          fontSize: AppFonts.size13,
          fontWeight: AppFonts.regular,
          fontFamily: 'Poppins',
        ),
        fillColor: widget.fillColor,
        filled: widget.filled,
        enabled: widget.enable,
        prefixIcon: widget.prefixIcon != null
            ? IconButton(
                onPressed: () {},
                icon: Image.asset(
                  widget.prefixIcon!,
                  width: widget.prefixHeight,
                  height: widget.prefixWidth,
                  color: widget.prefixiconcolor,
                  fit: BoxFit.cover,
                ),
              )
            : null,
        suffixIcon: widget.suffixIcon != null
            // ? widget.suffixIcon != icClose
            //     ? widget.suffixIcon != icApply
            //         ? widget.suffixIcon != icLocation
            //             ? widget.suffixIcon != icEditProfile
            ? GestureDetector(
                onTap: widget.onSuffixTap,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      widget.suffixIcon!,
                      color: widget.suffixiconcolor,
                      // color: Colors.red,
                      // fit: BoxFit.cover,
                      height: widget.suffixHeight,
                      width: widget.suffixWidth,
                    ),
                  ),
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            widget.borderradius,
          ),
          borderSide: BorderSide(
            width: 2.0,
            color: widget.borderColor,
          ),
        ),
        errorMaxLines: widget.errorMaxline,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderradius),
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderradius),
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderradius),
          borderSide: BorderSide(color: widget.borderColor, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderradius),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
    );
  }
}
