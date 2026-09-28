import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
 import 'package:flutter_nobrokeragefortenants/screens/add_property/add_properties_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/property_details/property_details.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_dropdown_cell.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/your_property_cell.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
import 'package:intl/intl.dart';

 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _searchController = TextEditingController();

  double priceRange = 10000.0;
  List floor = ["Ground floor", "First floor", "Second", "Third", "Any"];

  List category = ["Flat", "Bunglow", "Plant House", "Office", "Shop"];
  List format = ["1 BHK", "2 BHK", "3 BHK", "4 BHK"];

  List furnished = ["Fully", "Semi", "Unfurnished"];
  List<Data> yourproperty = [
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
    // MyYourPropertyWidget(
    //   propertydescription:
    //       "Golden swarnim business center is a commercial development in khoraj",
    //   propertyfloor: "Ground floor",
    //   propertyimage: AppIcons.icProperty,
    //   propertylocation: "South bopal, Ahmedabad",
    //   propertyname: "Swarnim Business Center",
    //   propertyprice: "25000",
    //   propertyresidence: "Commercial",
    //   propertysquarefeet: "750",
    // ),
  ];
  List option = ["All", "Commercial", "Residential"];
  int isSelected = 0;
  int isFloorSelected = 0;
  int isCategoerySelected = 0;
  int isFormatSelected = 0;
  int isFurnished = 0;
  String? selectedSize;
  String selectedStatus = 'all';
  Map<String, int> interestCounts = {};

  List<Data> get _allProperties => yourproperty;

  List<Data> _propertiesForStatus(String status) {
    if (status == 'all') return _allProperties;
    return _allProperties.where((property) {
      final value = (property.status ?? '').toLowerCase();
      return value == status;
    }).toList();
  }

  _poreprtiesApi({int? from}) async {
    var filterparams = {
      "search": _searchController.text.toString(),
      "category": category[isCategoerySelected] ?? "",
      "type": option[isSelected] ?? "",
      "format": format[isFormatSelected] ?? "",
      "furnished": furnished[isFurnished] ?? "",
      "priceRange": priceRange.toString() ?? "",
      "floor": floor[isFloorSelected] ?? "",
    };

    await Propertyapis.getproperties(
          isShowProgress: from == 0 ? true : false,
          context: context,
          id: Prefs.getString(LocalStrings.userid),
          params:
              from == 0
                  ? {}
                  : from == 2
                  ? {"search": _searchController.text.toString()}
                  : from == 3
                  ? {"type": isSelected == 0 ? "" : option[isSelected]}
                  : filterparams,
        )
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            isSelected = 0;
            isFloorSelected = 0;
            isCategoerySelected = 0;
            isFormatSelected = 0;
            isFurnished = 0;

            // selectedSize = '';

            log("APi Success");
            yourproperty = response.data ?? [];

            _brokerLeadsApi();
            setState(() {});
          } else {
            log("Api failed");
          }
        })
        .catchError((error) {
          yourproperty = [];

          setState(() {});
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  Future<void> _brokerLeadsApi() async {
    try {
      final response = await Authapi.brokerLeads(context: context, type: 'all');
      final payload =
          response is Map<String, dynamic> ? response['data'] : null;
      final leads =
          payload is Map<String, dynamic> ? payload['allLeads'] : null;
      final counts = <String, int>{};
      if (leads is List) {
        for (final item in leads.whereType<Map>()) {
          final lead = Map<String, dynamic>.from(item);
          final property =
              lead['property'] is Map
                  ? Map<String, dynamic>.from(lead['property'])
                  : lead;
          final id = property['_id'] ?? property['id'] ?? lead['propertyId'];
          if (id != null)
            counts[id.toString()] = (counts[id.toString()] ?? 0) + 1;
        }
      }
      if (mounted) setState(() => interestCounts = counts);
    } catch (_) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Durations.medium1, () {
      _poreprtiesApi(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 52,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _statusTab('All', 'all'),
                    _statusTab('Active', 'active'),
                    _statusTab('Inactive', 'inactive'),
                    _statusTab('Draft', 'draft'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [_getSearchbar()]),
            ),
            Expanded(
              child:
                  _propertiesForStatus(selectedStatus).isEmpty
                      ? Center(
                        child: Image.asset(
                          AppIcons.icNoPropertyImage,
                          width: screenSize!.width * .7,
                          fit: BoxFit.contain,
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _propertiesForStatus(selectedStatus).length,
                        itemBuilder:
                            (context, index) => _propertyRow(
                              _propertiesForStatus(selectedStatus)[index],
                            ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTab(String title, String status) {
    final selected = status == selectedStatus;
    final count = _propertiesForStatus(status).length;
    return Padding(
      padding: const EdgeInsets.only(right: 28),
      child: GestureDetector(
        onTap: () {
          setState(() => selectedStatus = status);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$title ($count)',
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.gray500,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              width: 76,
              color: selected ? AppColors.primary : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _propertyRow(Data property) {
    final imagePath =
        property.media?.isNotEmpty == true ? property.media!.first.path : null;
    final status =
        property.status?.isNotEmpty == true ? property.status! : 'Active';
    final interestCount = interestCounts[property.sId] ?? 0;
    return InkWell(
      onTap: () => _openProperty(property),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      imagePath == null
                          ? Image.asset(
                            AppIcons.icProperty,
                            width: 135,
                            height: 106,
                            fit: BoxFit.cover,
                          )
                          : CachedNetworkImage(
                            imageUrl: '${AppEndpoints.imgUrl}$imagePath',
                            width: 135,
                            height: 106,
                            fit: BoxFit.cover,
                            errorWidget:
                                (_, __, ___) => Image.asset(
                                  AppIcons.icProperty,
                                  fit: BoxFit.cover,
                                ),
                          ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffdff1e1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title ?? 'Untitled property',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    property.location ?? property.area ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '₹${property.price ?? 0} / month',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.bed_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.format ?? '-',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.bathtub_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        property.furnished ?? '-',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.square_foot,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${property.size ?? property.area ?? '-'}',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '$interestCount',
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProperty(Data property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MyPropertyDetails(
              sizetype: property.sizeType ?? '',
              type: property.type ?? '',
              size: property.size ?? '',
              images: property.media ?? [],
              squarefeet: property.sizeType ?? '',
              companyname: property.title ?? '',
              price: '${property.price ?? 0}',
              address: property.location ?? '',
              description: property.description ?? '',
              format: property.format ?? '',
              category: property.category ?? '',
              furnished: property.furnished ?? '',
              area: property.area ?? '',
              negotiable: '',
              propertyid: property.sId ?? '',
              floor: property.floor ?? '',
            ),
      ),
    );
  }

  _getBottomSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (builder) {
      return StatefulBuilder(
        builder: (context, mystate) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(38),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 44.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Stack(
                      children: [
                        Center(
                          child: getTextWidget(
                            title: 'Filter',
                            textFontSize: AppFonts.size22,
                            textFontWeight: AppFonts.bold,
                            textColor: AppColors.blackColor,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              mystate(() {
                                Navigator.pop(context);

                                _poreprtiesApi(from: 0);

                                isSelected = 0;
                                isFloorSelected = 0;
                                isCategoerySelected = 0;
                                isFormatSelected = 0;
                                isFurnished = 0;

                                // selectedSize = '';
                              });
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: getTextWidget(
                                title: 'Clear',
                                textFontSize: AppFonts.size14,
                                textColor: AppColors.primary,
                                textFontWeight: AppFonts.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  getTextWidget(
                    title: 'Floor',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.bold,
                    textColor: AppColors.blackColor,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    children: List.generate(floor.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            mystate(() {
                              isFloorSelected = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isFloorSelected == index
                                      ? AppColors.lightgreen
                                      : AppColors.secondwhite,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color:
                                    isFloorSelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 1.0,
                                bottom: 1.0,
                                left: 10,
                                right: 11.0,
                              ),
                              child: getTextWidget(
                                title: floor[index],
                                textFontSize: AppFonts.size12,
                                textColor:
                                    isFloorSelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 21.0),
                  getTextWidget(
                    title: 'Price Range',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.bold,
                    textColor: AppColors.blackColor,
                  ),

                  Slider(
                    value: priceRange,
                    min: 1000.0,
                    max: 50000.0,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.thirdwhite,
                    label: priceRange.round().toString(),
                    onChanged: (double value) {
                      mystate(() {
                        priceRange = value;
                      });
                    },
                  ),

                  const SizedBox(height: 21),
                  getTextWidget(
                    title: 'Category',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.bold,
                    textColor: AppColors.blackColor,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    children: List.generate(category.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            mystate(() {
                              isCategoerySelected = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isCategoerySelected == index
                                      ? AppColors.lightgreen
                                      : AppColors.secondwhite,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color:
                                    isCategoerySelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 1.0,
                                bottom: 1.0,
                                left: 10,
                                right: 11.0,
                              ),
                              child: getTextWidget(
                                title: category[index],
                                textFontSize: AppFonts.size12,
                                textColor:
                                    isCategoerySelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 21),
                  getTextWidget(
                    title: 'Format',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.bold,
                    textColor: AppColors.blackColor,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    children: List.generate(format.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            mystate(() {
                              isFormatSelected = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isFormatSelected == index
                                      ? AppColors.lightgreen
                                      : AppColors.secondwhite,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color:
                                    isFormatSelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 1.0,
                                bottom: 1.0,
                                left: 10,
                                right: 11.0,
                              ),
                              child: getTextWidget(
                                title: format[index],
                                textFontSize: AppFonts.size12,
                                textColor:
                                    isFormatSelected == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 21),
                  // getTextWidget(
                  //   title: 'Size type',
                  //   textFontSize: AppFonts.size15,
                  //   textFontWeight: AppFonts.bold,
                  //   textColor: AppColors.blackColor,
                  // ),
                  MyCustomizeDropdown(
                    selectedValue: selectedSize,
                    fontsize: AppFonts.size15,
                    fontwieght: AppFonts.bold,
                    labelText: "Size type",
                    onChanged: (v) {
                      mystate(() {
                        selectedSize = v;
                      });
                    },
                    items: ["Square foot", "Square Yard"],
                  ),
                  const SizedBox(height: 21),
                  getTextWidget(
                    title: 'Furnished',
                    textFontSize: AppFonts.size15,
                    textFontWeight: AppFonts.bold,
                    textColor: AppColors.blackColor,
                  ),
                  const SizedBox(height: 8.0),
                  Wrap(
                    children: List.generate(furnished.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 6.0),
                        child: GestureDetector(
                          onTap: () {
                            mystate(() {
                              isFurnished = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isFurnished == index
                                      ? AppColors.lightgreen
                                      : AppColors.secondwhite,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color:
                                    isFurnished == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 1.0,
                                bottom: 1.0,
                                left: 10,
                                right: 11.0,
                              ),
                              child: getTextWidget(
                                title: furnished[index],
                                textFontSize: AppFonts.size12,
                                textColor:
                                    isFurnished == index
                                        ? AppColors.primary
                                        : AppColors.bordercolor,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 21.0),

                  CustomizedButton(
                    buttonColor: AppColors.primary,
                    title: 'Filter Properties',
                    textColor: AppColors.secondary,
                    onTap: () {
                      // Navigator.pop(context);
                      _poreprtiesApi(from: 1);

                      mystate(() {});
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  _getProperties() => Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: ListView.builder(
          itemCount: yourproperty.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return GestureDetector(
              // behavior: HitTestBehavior.translucent,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => MyPropertyDetails(
                          sizetype: yourproperty[index].sizeType!,
                          type: yourproperty[index].type!,
                          size: yourproperty[index].size!,
                          images: yourproperty[index].media!,
                          squarefeet: yourproperty[index].sizeType!,
                          companyname: yourproperty[index].title!,
                          price: yourproperty[index].price!.toString(),
                          address: yourproperty[index].location!,
                          description: yourproperty[index].description!,
                          format: yourproperty[index].format!,
                          category: yourproperty[index].category!,
                          furnished: yourproperty[index].furnished!,
                          area: yourproperty[index].area!,
                          negotiable: "",
                          propertyid: yourproperty[index].sId!,
                          floor: yourproperty[index].floor!,
                        ),
                  ),
                );

                if (result != null) {
                  await _poreprtiesApi();
                }
              },
              child: MyYourPropertyWidget(
                index: index,
                onRefresh: () async {
                  await _poreprtiesApi();
                },
                propertyId: yourproperty[index].sId!,
                propertydescription: yourproperty[index].description,
                propertyfloor: yourproperty[index].floor,
                propertyimage: yourproperty[index].media,
                propertylocation: yourproperty[index].location,
                propertyname: yourproperty[index].title,
                propertyprice: yourproperty[index].price!.toString(),
                propertyresidence: yourproperty[index].type,
                propertysquarefeet: yourproperty[index].sizeType,
                propertyData: yourproperty,
              ),
            );
          },
        )
        .animate()
        .fade(duration: 800.ms)
        .slideY(begin: 0.5)
        .scale(begin: const Offset(0.8, 0.8))
        .then(delay: 200.ms),
  );

  _getOptions() => Padding(
    padding: const EdgeInsets.only(top: 11.0),
    child: Container(
      width: screenSize!.width,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFFDFE0E2), width: 1.0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          top: 6.39,
          bottom: 6.39,
          right: 10.34,
        ),
        child: SizedBox(
          height: 38,
          child: ListView.builder(
            itemCount: option.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  isSelected = index;
                  setState(() {});
                  _poreprtiesApi(from: 3);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          isSelected == index
                              ? AppColors.secondary
                              : const Color(0XFFF4F4F4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: getTextWidget(
                        title: option[index],
                        textFontSize: AppFonts.size13,
                        textFontWeight: AppFonts.semiBold,
                        textColor:
                            isSelected == index
                                ? AppColors.white
                                : const Color(0xffA1A9B8),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  _getSearchbar() => Container(
    width: screenSize!.width / 1.5,
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        // BoxShadow(
        //   spreadRadius: 1,
        //   blurRadius: 0,
        //   offset: const Offset(0, 0),
        //   color: const Color(0XFF68718229).withValues(alpha: 16.0),
        // ),
        // const BoxShadow(
        //   spreadRadius: 0,
        //   blurRadius: 2,
        //   offset: Offset(0, 1),
        //   color: Color(0Xff0000000f),
        // ),
      ],
    ),
    child: PrimaryTextFeild(
      textInputAction: TextInputAction.search,
      hintText: 'Search...',
      hintColor: const Color(0XFFA1A9B8),
      controller: _searchController,

      onfeildSubmitted: (value) {
        setState(() {
          _poreprtiesApi(from: 2);
        });
      },
      // borderColor: AppColors.white,
      // onChange: (value) {
      //   _poreprtiesApi(from: 2);
      //   setState(() {});
      // },
      prefixIcon: AppIcons.icSearch,
      prefixiconcolor: const Color(0XFFA1A9B8),
    ),
  );

  _getFilter() => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      _getBottomSheet();
    },
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 14.0,
          top: 8.0,
          bottom: 9.0,
          right: 5.0,
        ),
        child: Row(
          children: [
            getTextWidget(
              title: 'Filter',
              textFontSize: AppFonts.size15,
              textFontWeight: AppFonts.bold,
              textColor: AppColors.white,
            ),
            Image.asset(
              AppIcons.icFilter,
              height: 22,
              width: 22,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    ),
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
