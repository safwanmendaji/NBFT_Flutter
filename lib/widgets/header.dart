import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';

class MyCustomHeader extends StatefulWidget {
  final bool isBackButton;
  final String title;

  const MyCustomHeader({
    super.key,
    required this.title,
    this.isBackButton = false,
  });

  @override
  State<MyCustomHeader> createState() => _MyCustomheaderState();
}

class _MyCustomheaderState extends State<MyCustomHeader> {
  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return _getHeader();
  }

  _getHeader() => Container(
    width: screenSize!.width,
    decoration: const BoxDecoration(color: AppColors.secondary),
    child: Padding(
      padding: EdgeInsets.only(
        top: 8.0,
        left: widget.isBackButton ? 16.0 : 28.0,
        bottom: 6.0,
      ),
      child: Row(
        children: [
          widget.isBackButton
              ? IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: AppColors.white,
                ),
              )
              : Container(),

          const SizedBox(width: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTextWidget(
                title: widget.title,
                textFontSize: AppFonts.size18,
                textColor: AppColors.blackColor,
                textFontWeight: AppFonts.bold,
              ),
              _getCurrentDay(),
            ],
          ),
        ],
      ),
    ),
  );

  _getCurrentDay() => SizedBox(
    child: getTextWidget(
      textAlign: TextAlign.end,
      title: getFormattedDate(),
      textFontSize: AppFonts.size13,
      textFontWeight: AppFonts.semiBold,
      textColor: AppColors.white,
    ),
  );
}
// class MyCustomHeader extends StatefulWidget {
//   final bool? isBacButton;
//   final ScrollController? scrollController;

//   const MyCustomHeader({
//     super.key,
//     this.isBacButton = false,
//     this.scrollController,
//   });

//   @override
//   State<MyCustomHeader> createState() => _MyCustomHeaderState();
// }

// class _MyCustomHeaderState extends State<MyCustomHeader>
//     with SingleTickerProviderStateMixin {
//   double offset = 0.0;
//   late AnimationController _controller;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     // Set up animation
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset.zero,
//       end: const Offset(0, -1.0), // Slide up
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     // Listen to scroll changes if scrollController is passed
//     widget.scrollController?.addListener(_scrollListener);
//   }

//   void _scrollListener() {
//     if (widget.scrollController == null) return;

//     if (widget.scrollController!.position.userScrollDirection ==
//         ScrollDirection.reverse) {
//       _controller.forward(); // hide header
//     } else if (widget.scrollController!.position.userScrollDirection ==
//         ScrollDirection.forward) {
//       _controller.reverse(); // show header
//     }
//   }

//   @override
//   void dispose() {
//     widget.scrollController?.removeListener(_scrollListener);
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Container(
//         decoration: const BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Color.fromARGB(255, 35, 107, 98),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//               spreadRadius: 2,
//             )
//           ],
//           color: AppColors.white,
//           borderRadius: BorderRadius.only(
//             bottomLeft: Radius.circular(25),
//             bottomRight: Radius.circular(25),
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Row(
//             children: [
//               if (widget.isBacButton!)
//                 Padding(
//                   padding: const EdgeInsets.only(left: 8.0, right: 16.0),
//                   child: Container(
//                     height: 50,
//                     width: 50,
//                     decoration: const BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: AppColors.primary,
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       icon: const Icon(
//                         Icons.arrow_back,
//                         size: 24,
//                         color: AppColors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               Image.asset(
//                 AppIcons.icApp,
//                 height: 50,
//                 width: 100,
//                 fit: BoxFit.cover,
//               ),
//               const Spacer(),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15.0, left: 15.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     SizedBox(
//                       width: screenSize!.width - 300,
//                       child: getTextWidget(
//                         title: Prefs.getString(LocalStrings.username),
//                         maxLines: 1,
//                         textFontWeight: AppFonts.bold,
//                         textFontSize: AppFonts.size22,
//                         textColor: AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
