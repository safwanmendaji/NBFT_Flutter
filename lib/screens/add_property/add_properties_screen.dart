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

class PropertyPurposeScreen extends StatefulWidget {
  const PropertyPurposeScreen({super.key});

  @override
  State<PropertyPurposeScreen> createState() =>
      _PropertyPurposeScreenState();
}

class _PropertyPurposeScreenState
    extends State<PropertyPurposeScreen> {
  int selectedListing = 1; // 0 = Sell, 1 = Rent
  String selectedPurpose = 'Residential';
  bool isSelect = true;
  String selectedListingCategory = 'Rent';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Property Listing',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --------------------------------------------------
                    // HEADER
                    // --------------------------------------------------
                    Text(
                      'What kind of property\nlisting?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose how you want to list your property.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --------------------------------------------------
                    // SELL / RENT
                    // --------------------------------------------------
                    _listingTypeSelector(context),

                    const SizedBox(height: 30),

                    // --------------------------------------------------
                    // PURPOSE TITLE
                    // --------------------------------------------------
                    Row(
                      children: [
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color:  AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.home_work_outlined,
                            size: 19,
                            color:  AppColors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Purpose of property',
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Select the type that best describes your property.',
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                  colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // --------------------------------------------------
                    // COMMERCIAL
                    // --------------------------------------------------
                    _purposeCard(
                      context: context,
                      title: 'Commercial',
                      subtitle:
                      'For business and commercial purposes',
                      icon: Icons.business_rounded,
                      value: 'Commercial',
                      accentColor:  AppColors.primary,
                      points: const [
                        'Suitable for commercial use',
                        '40% of your budget amount is required',
                        'Ideal for shops, offices and businesses',
                      ],
                    ),

                    const SizedBox(height: 14),

                    // --------------------------------------------------
                    // RESIDENTIAL
                    // --------------------------------------------------
                    _purposeCard(
                      context: context,
                      title: 'Residential',
                      subtitle:
                      'For living and personal use',
                      icon: Icons.home_rounded,
                      value: 'Residential',
                      accentColor:  AppColors.primary,
                      points: const [
                        'Suitable for residential living',
                        '20% of your budget amount is required',
                        'Ideal for houses, flats and bungalows',
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------
            // BOTTOM BUTTON
            // ----------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: () {
                    print("SELECTED ${selectedPurpose}");
                    print("SELECTED ${selectedListing}");
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyAddPropertyForm(
                              type: selectedPurpose,
                              category: selectedListing==0?"Sell":"Rent",
                              from: "Add",
                            )));
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SELL / RENT SELECTOR
  // ================================================================

  Widget _listingTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        //color:  AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: AppColors.blackColor.withValues(alpha: 0.4)
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: _listingButton(
              context: context,
              title: 'Sell Property',
              icon: Icons.sell_outlined,
              selected: selectedListing == 0,
              onTap: () {
                setState(() {
                  selectedListing = 0;
                });
              },
            ),
          ),
          Expanded(
            child: _listingButton(
              context: context,
              title: 'Rent Property',
              icon: Icons.key_rounded,
              selected: selectedListing == 1,
              onTap: () {
                setState(() {
                  selectedListing = 1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _listingButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Material(
        color: selected
            ?  AppColors.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected
                      ? AppColors.white
                      : AppColors.blackColor.withValues(alpha: 0.4)
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? AppColors.white
                          : AppColors.blackColor.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // PURPOSE CARD
  // ================================================================

  Widget _purposeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Color accentColor,
    required List<String> points,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selected = selectedPurpose == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? accentColor.withValues(alpha: 0.10)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected
              ? accentColor
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: selected ? 1.8 : 1,
        ),
        boxShadow: selected
            ? [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            setState(() {
              selectedPurpose = value;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ------------------------------------------------------
                // HEADER
                // ------------------------------------------------------
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? accentColor
                            : accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        color: selected
                            ? Colors.white
                            : accentColor,
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                            theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style:
                            theme.textTheme.bodySmall?.copyWith(
                              color:
                              colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Selection indicator
                    AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 200),
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? accentColor
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? accentColor
                              : colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                      child: selected
                          ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------------
                // INFORMATION
                // ------------------------------------------------------
                ...points.map(
                      (point) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: 11,
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(
                            top: 5,
                          ),
                          height: 7,
                          width: 7,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            point,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                              height: 1.35,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ------------------------------------------------------
                // SELECT LABEL
                // ------------------------------------------------------
                const SizedBox(height: 2),

                AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? accentColor.withValues(alpha: 0.12)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked,
                        size: 17,
                        color: selected
                            ? accentColor
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        selected
                            ? 'Selected'
                            : 'Select $title',
                        style:
                        theme.textTheme.labelLarge?.copyWith(
                          color: selected
                              ? accentColor
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
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
    getScreenSize(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //const MyCustomHeaderLogo(),
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
                width: screenSize?.width??0,
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
                  width: screenSize?.width,
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
