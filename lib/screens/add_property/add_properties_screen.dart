import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/screens/add_property/property_form.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';

class MyAddPropertiesScreen extends StatefulWidget {
  const MyAddPropertiesScreen({
    super.key,
  });

  @override
  State<MyAddPropertiesScreen> createState() => _MyAddPropertiesScreenState();
}

class _MyAddPropertiesScreenState extends State<MyAddPropertiesScreen> {
  final ScrollController _scrollController = ScrollController();

  List commercial = [
    "Select this if you want the property for Commercial  purpose.",
    "In Commercial you have to pay 40% of your budget amount",
    "In Commercial you have to pay 40% of your budget amount"
  ];

  List residential = [
    "Select this if you want the property for living purpose.",
    "In residential you have to pay 20% of your budget amount",
    "In residential you have to pay 20% of your budget amount"
  ];

  bool isSelect = true;
  String selectedListingCategory = 'Rent';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            title: "Add Property",
            // scrollController: _scrollController,
          ),
          Expanded(
              child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, left: 35.0, right: 34.0),
                        child: getTextWidget(
                            textAlign: TextAlign.center,
                            title: 'What kind of property listing?',
                            textFontSize: AppFonts.size15,
                            textFontWeight: AppFonts.bold,
                            textColor: AppColors.white),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildListingTab(
                                label: 'Sell Property',
                                isSelected: selectedListingCategory == 'Sell',
                                onTap: () => setState(() => selectedListingCategory = 'Sell'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildListingTab(
                                label: 'Rent Property',
                                isSelected: selectedListingCategory == 'Rent',
                                onTap: () => setState(() => selectedListingCategory = 'Rent'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 35.0, right: 35.0),
                        child: getTextWidget(
                            textAlign: TextAlign.center,
                            title: 'Your purpose for property?',
                            textFontSize: AppFonts.size13,
                            textColor: AppColors.white,
                            textFontWeight: AppFonts.extraLight),
                      ),
                      _getCards()
                    ],
                  )))
        ],
      ),
      bottomNavigationBar: _getButton(),
    );
  }

  Widget _buildListingTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: getTextWidget(
            title: label,
            textFontSize: AppFonts.size13,
            textFontWeight: AppFonts.bold,
            textColor: AppColors.white,
          ),
        ),
      ),
    );
  }

  _getButton() => Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: CustomizedButton(
          title: 'Next',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MyAddPropertyForm(
                          type: isSelect ? "Commercial" : "Residential",
                          category: selectedListingCategory,
                          from: "Add",
                        )));
          },
        ),
      );

  _getCards() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 34.0,
              right: 34.0,
              top: 22.0,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                setState(() {
                  isSelect = true;
                });
              },
              child: Container(
                width: screenSize!.width,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 2),
                  borderRadius: BorderRadius.circular(34),
                  gradient: isSelect
                      ? const LinearGradient(
                          colors: [Color(0xff806E56), Color(0xff1A1611)],
                        )
                      : const LinearGradient(
                          colors: [Color(0xff11504F), Color(0xffff176866)],
                        ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 17.0, left: 23.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            AppIcons.icCommercial,
                            height: 21,
                            width: 23,
                            color: AppColors.white,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          getTextWidget(
                            title: 'Commercial',
                            textFontSize: AppFonts.size20,
                            textFontWeight: AppFonts.bold,
                            textColor: AppColors.white,
                          )
                        ],
                      ),
                      ListView.builder(
                          itemCount: commercial.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 25.0),
                                  child: Container(
                                    height: 8.0,
                                    width: 8.0,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: 35.0,
                                    top: 20,
                                  ),
                                  child: SizedBox(
                                    width: screenSize!.width - 155,
                                    child: getTextWidget(
                                        title: commercial[index],
                                        textFontSize: AppFonts.size12,
                                        textFontWeight: AppFonts.semiBold,
                                        textColor: AppColors.white,
                                        maxLines: 2),
                                  ),
                                )
                              ],
                            );
                          })
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fade(duration: 800.ms)
              .slideY(begin: 0.5)
              .scale(begin: const Offset(0.8, 0.8))
              .then(delay: 200.ms),
          Padding(
            padding: const EdgeInsets.only(
                left: 34.0, right: 34.0, top: 22.0, bottom: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSelect = false;
                });
              },
              child: Container(
                  width: screenSize!.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.white, width: 2),
                    borderRadius: BorderRadius.circular(34),
                    gradient: isSelect != true
                        ? const LinearGradient(
                            colors: [Color(0xff806E56), Color(0xff1A1611)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xff11504F), Color(0xffff176866)],
                          ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 17.0, left: 23.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppIcons.icResidental,
                              height: 31,
                              width: 31,
                              color: AppColors.white,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            getTextWidget(
                                title: 'Residential',
                                textFontSize: AppFonts.size20,
                                textFontWeight: AppFonts.bold,
                                textColor: AppColors.white)
                          ],
                        ),
                        ListView.builder(
                            itemCount: residential.length,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 25.0),
                                    child: Container(
                                      height: 8.0,
                                      width: 8.0,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16.0,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 35.0,
                                      top: 20,
                                    ),
                                    child: SizedBox(
                                      width: screenSize!.width - 160,
                                      child: getTextWidget(
                                          title: residential[index],
                                          textFontSize: AppFonts.size12,
                                          textColor: AppColors.white,
                                          maxLines: 2),
                                    ),
                                  )
                                ],
                              );
                            })
                      ],
                    ),
                  )),
            ),
          )
              .animate()
              .fade(duration: 800.ms)
              .slideY(begin: 0.5)
              .scale(begin: const Offset(0.8, 0.8))
              .then(delay: 200.ms),
        ],
      );

  _getCurrentDay() => Padding(
        padding: const EdgeInsets.only(top: 1.0, left: 33.0),
        child: getTextWidget(
          title: getFormattedDate(),
          textFontSize: AppFonts.size16,
          textColor: AppColors.daycolor,
        ),
      );
}
