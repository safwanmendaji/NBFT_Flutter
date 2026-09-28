import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';

class CustomizedAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomizedAppBar({
    super.key,
    this.title = '',
    this.actions,
    this.centerTitle = true,
    this.isBackIcon = true,
  });
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool isBackIcon;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(
                width: 20,
              ),
            ]
          : actions,
      leading: isBackIcon
          ? IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.white,
                size: 24,
              ),
            )
          : null,
      centerTitle: centerTitle,
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(fontSize: AppFonts.size15, color: AppColors.white),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}
