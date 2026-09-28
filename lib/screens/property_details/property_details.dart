import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
 import 'package:flutter_nobrokeragefortenants/screens/add_property/add_properties_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/add_property/property_form.dart';
 import 'package:flutter_nobrokeragefortenants/screens/customer_details/customer_details.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

 import 'package:flutter_nobrokeragefortenants/widgets/video_player_widget.dart';

class MyPropertyDetails extends StatefulWidget {
  final List<Media> images;
  final String companyname;
  final String propertyid;
  final String price;
  final String address;
  final String description;
  final String squarefeet;
  final String format;
  final String category;
  final String furnished;
  final String area;
  final String size;
  final String floor;
  final String type;
  final String sizetype;
  final String negotiable;
  const MyPropertyDetails(
      {super.key,
      required this.images,
      required this.type,
      required this.companyname,
      required this.price,
      required this.address,
      required this.description,
      required this.squarefeet,
      required this.format,
      required this.category,
      required this.furnished,
      required this.area,
      required this.size,
      required this.negotiable,
      required this.propertyid,
      required this.floor,
      required this.sizetype});

  @override
  State<MyPropertyDetails> createState() => _MyPropertyDetailsState();
}

class _MyPropertyDetailsState extends State<MyPropertyDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    // TODO: implement initState
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true); // continuous up and down

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05), // move upward slightly
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int _currentIndex = 0;
  List specification = [];
  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      // Step 1: Download video file
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        // Step 2: Get temp directory
        final tempDir = await getTemporaryDirectory();
        final tempVideoPath = '${tempDir.path}/temp_video.mp4';

        // Step 3: Write to file
        final file = File(tempVideoPath);
        await file.writeAsBytes(response.bodyBytes);

        // Step 4: Generate thumbnail from local file path
        final uint8list = await VideoThumbnail.thumbnailData(
          video: tempVideoPath,
          imageFormat: ImageFormat.PNG,
          maxHeight: 400,
          quality: 50,
        );

        return uint8list;
      } else {
        log('Failed to download video');
        return null;
      }
    } catch (e) {
      log('Error generating thumbnail: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    specification = [
      {
        'icon': AppIcons.icBothSideArrow,
        'title': 'Size',
        'isicon': false,
        'subtitle': "${widget.size} ${widget.sizetype}"
      },
      {
        'icon': Icons.bed,
        'title': 'BHK',
        'isicon': true,
        'subtitle': "${widget.format}",
      },
      {
        'icon': AppIcons.icCategory,
        'title': 'Category',
        'isicon': false,
        'subtitle': "${widget.category}",
      },
      {
        'icon': Icons.area_chart,
        'title': 'Area',
        'isicon': true,
        'subtitle': "${widget.area}",
      },
      {
        'icon': Icons.home,
        'title': 'Floor',
        'isicon': true,
        'subtitle': "${widget.floor}",
      },
      {
        'icon': Icons.bedroom_parent_sharp,
        'title': 'Furnished',
        'isicon': true,
        'subtitle': "${widget.furnished}",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(
            title: "Property Details",
            isBackButton: true,
          ),

          // _getCurrentDay(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getImageList(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 10.0, left: 16.0, right: 16.0),
                    child: SizedBox(
                      width: screenSize!.width,
                      child: getTextWidget(
                          title: widget.companyname,
                          maxLines: 2,
                          textFontSize: AppFonts.size17,
                          textFontWeight: AppFonts.bold,
                          textColor: AppColors.primary),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, right: 90.0, left: 16.0),
                      child: Row(
                        children: [
                          Image.asset(
                            AppIcons.icRuppee,
                            height: 15,
                            width: 15,
                            color: AppColors.secondary,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(
                            width: 5.0,
                          ),
                          getTextWidget(
                              title:
                                  '${NumberFormat.decimalPattern('en_IN').format(int.tryParse(widget.price.toString() ?? '0') ?? 0)} /-',
                              textFontSize: AppFonts.size17,
                              textFontWeight: AppFonts.semiBold,
                              textColor: AppColors.secondary),
                        ],
                      )),
                  _getDivider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16.0),
                    child: getTextWidget(
                        title: 'Address',
                        textFontSize: AppFonts.size15,
                        textFontWeight: AppFonts.bold,
                        textColor: AppColors.primary),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 8.0, right: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            const BoxShadow(
                                spreadRadius: 1,
                                offset: Offset(0, 0),
                                blurRadius: 5,
                                color: AppColors.primary,
                                blurStyle: BlurStyle.outer)
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Image.asset(
                                AppIcons.icLocation,
                                height: 15,
                                width: 15,
                                color: AppColors.blackColor,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            SizedBox(
                              width: screenSize!.width - 70,
                              child: getTextWidget(
                                  title: widget.address,
                                  // maxLines: 4,
                                  textFontSize: AppFonts.size15,
                                  textFontWeight: AppFonts.semiBold,
                                  textColor: AppColors.blackColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, left: 16.0),
                    child: getTextWidget(
                        title: 'Description',
                        textFontSize: AppFonts.size15,
                        textFontWeight: AppFonts.bold,
                        textColor: AppColors.primary),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8.0, left: 16.0, right: 16),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            const BoxShadow(
                                spreadRadius: 1,
                                offset: Offset(0, 0),
                                blurRadius: 5,
                                color: AppColors.primary,
                                blurStyle: BlurStyle.outer)
                          ],
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: getTextWidget(
                          title: widget.description,
                          // textFontSize: AppFonts.size15,
                          textFontWeight: AppFonts.semiBold,
                          textColor: AppColors.blackColor,
                        ),
                      ),
                    ),
                  ),
                  _getPropertySpecification(),
                  _getButton(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _getPropertySpecification() => Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            getTextWidget(
                title: 'Property Specifications',
                textFontSize: AppFonts.size18,
                textFontWeight: AppFonts.bold,
                textColor: AppColors.primary),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: specification.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.only(top: 16, bottom: 8.0),
                    // height: 100,
                    width: screenSize!.width / 2,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: 2,
                            offset: const Offset(0, 0),
                            blurRadius: 4,
                            color: AppColors.blackColor.withValues(alpha: 0.25),
                            blurStyle: BlurStyle.outer)
                      ],
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(
                      //   width: 1,
                      //   color: AppColors.primary,
                      // ),
                    ),
                    child: Column(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _offsetAnimation,
                          child: Container(
                            decoration: const BoxDecoration(boxShadow: [
                              BoxShadow(
                                  spreadRadius: 1,
                                  offset: Offset(0, 0),
                                  blurRadius: 5,
                                  color: AppColors.primary,
                                  blurStyle: BlurStyle.outer)
                            ], color: AppColors.white, shape: BoxShape.circle),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: specification[index]['isicon']
                                  ? Icon(
                                      specification[index]['icon'],
                                      size: 24,
                                      color: AppColors.primary,
                                    )
                                  : Image.asset(
                                      specification[index]['icon'],
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.cover,
                                      color: AppColors.primary,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 4.0,
                        ),
                        getTextWidget(
                            title: specification[index]['title'],
                            textFontWeight: AppFonts.medium,
                            textFontSize: AppFonts.size17,
                            textColor: AppColors.darkblack),
                        getTextWidget(
                            title: '${specification[index]['subtitle']}',
                            // textFontSize: AppFonts.size15,
                            textFontWeight: AppFonts.semiBold,
                            textAlign: TextAlign.center,
                            textColor: AppColors.primary),
                      ],
                    ),
                  );
                },
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 135,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                ),
              ),
            ),

            // _getDivider(),
            // const SizedBox(
            //   height: 18.0,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         getTextWidget(
            //             title: widget.category,
            //             textFontSize: AppFonts.size15,
            //             textColor: AppColors.white,
            //             textFontWeight: AppFonts.semiBold),
            //         getTextWidget(
            //             title: 'Category',
            //             textFontSize: AppFonts.size12,
            //             textFontWeight: AppFonts.medium,
            //             textColor: AppColors.white)
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         getTextWidget(
            //             title: widget.furnished,
            //             textFontSize: AppFonts.size15,
            //             textFontWeight: AppFonts.semiBold,
            //             textColor: AppColors.white),
            //         getTextWidget(
            //             title: 'Format',
            //             textFontWeight: AppFonts.medium,
            //             textFontSize: AppFonts.size12,
            //             textColor: AppColors.white)
            //       ],
            //     )
            //   ],
            // ),
            // _getDivider(),
            // const SizedBox(
            //   height: 18.0,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         getTextWidget(
            //             title: widget.area,
            //             textFontSize: AppFonts.size15,
            //             textFontWeight: AppFonts.semiBold,
            //             textColor: AppColors.white),
            //         getTextWidget(
            //             title: 'Area',
            //             textFontSize: AppFonts.size12,
            //             textFontWeight: AppFonts.medium,
            //             textColor: AppColors.white)
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.end,
            //       children: [
            //         SizedBox(
            //           width: screenSize!.width - 250,
            //           child: getTextWidget(
            //               title: widget.floor,
            //               maxLines: 1,
            //               textFontSize: AppFonts.size15,
            //               textFontWeight: AppFonts.semiBold,
            //               textColor: AppColors.white),
            //         ),
            //         getTextWidget(
            //             title: 'Floor',
            //             textFontWeight: AppFonts.medium,
            //             textFontSize: AppFonts.size12,
            //             textColor: AppColors.white)
            //       ],
            //     )
            //   ],
            // ),
            // _getDivider(),
            // const SizedBox(
            //   height: 18.0,
            // ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     getTextWidget(
            //         title: 'Negotiable',
            //         textFontSize: AppFonts.size15,
            //         textFontWeight: AppFonts.semiBold,
            //         textColor: AppColors.white),
            //     getTextWidget(
            //         title: 'Water supply',
            //         textFontWeight: AppFonts.semiBold,
            //         textFontSize: AppFonts.size15,
            //         textColor: AppColors.white)
            //   ],
            // ),

            // _getDivider(),
          ],
        ),
      );

  _getButton() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 7.0,
              right: 7.0,
              top: 40.0,
            ),
            child: GestureDetector(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyAddPropertyForm(
                      media: widget.images,
                      propertyId: widget.propertyid,
                      from: "Edit",

                      type: widget.type,
                      propertyaddress: widget.address,
                      propertydescription: widget.description,
                      propertyname: widget.companyname,
                      propertypincode: "380001",
                      propertyprice: widget.price.toString(),
                      propertysize: widget.size,
                      selectArea: widget.area,
                      selectCity: "Ahmedabad",
                      selectFloor: widget.floor,
                      selectFormat: widget.format,
                      selectFurnished: widget.furnished,
                      // selectNegotiation: "",
                      selectSizetype: widget.sizetype,
                      selectState: "Gujarat",
                      // selectedCategory: widget
                      //     .category,
                    ),
                  ),
                );
              },
              child: Container(
                height: 47,
                width: screenSize!.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: AppColors.secondary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.icEditOutline,
                      height: 26,
                      width: 26,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 13.0,
                    ),
                    getTextWidget(
                        title: 'Edit Property',
                        textFontSize: AppFonts.size16,
                        textFontWeight: AppFonts.bold,
                        textColor: AppColors.white)
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 18.0,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7.0, right: 7.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyCustomerDetails(propertyId: widget.propertyid)));
              },
              child: Container(
                height: 47,
                width: screenSize!.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: AppColors.secondary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppIcons.icCustomerDetail,
                      height: 26,
                      width: 26,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(
                      width: 13.0,
                    ),
                    getTextWidget(
                        title: 'Customer Details',
                        textFontSize: AppFonts.size16,
                        textFontWeight: AppFonts.bold,
                        textColor: AppColors.white)
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      );

  _getDivider() => Padding(
        padding: const EdgeInsets.only(left: 4.0, right: 3.0, top: 20.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: AppColors.white,
            ),
          ),
          height: 1,
          width: screenSize!.width,
        ),
      );

  _getImageList() => Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SizedBox(
            height: 280,
            child: PageView.builder(
                itemCount: widget.images.length,
                scrollDirection: Axis.horizontal,
                // shrinkWrap: true,
                onPageChanged: (v) {
                  setState(() {
                    _currentIndex = v;
                  });
                },
                itemBuilder: (context, index) {
                  return widget.images[index].type == "image"
                      ? CachedNetworkImage(
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 280,
                              decoration:
                                  const BoxDecoration(color: Colors.grey),
                            ),
                          ),
                          imageUrl:
                              "${AppEndpoints.imgUrl}${widget.images[index].path}",
                          height: 280,
                          width: screenSize!.width,
                          fit: BoxFit.cover,
                        )
                      : Stack(
                          children: [
                            FutureBuilder<Uint8List?>(
                              future: generateThumbnail(
                                  "${AppEndpoints.imgUrl}${widget.images[index].path!.toString()}"),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.done &&
                                    snapshot.hasData) {
                                  // log(' The data is here  ${snapshot.data}');
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.95),
                                        child: Stack(
                                          children: [
                                            Image.memory(
                                              snapshot.data!,
                                              height: 280,
                                              width: screenSize!.width,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewVideoPlay(
                                                          type: 'url',
                                                          pathh:
                                                              "${AppEndpoints.imgUrl}${widget.images[index].path!}",
                                                        ),
                                                      ),
                                                    );

                                                    log("This is the url ${AppEndpoints.imgUrl}${widget.images[index].path!}");
                                                  },
                                                  icon: const Icon(
                                                    Icons.play_circle_fill,
                                                    size: 48,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // log(' The data is loading....  ${snapshot.data}');

                                  return Shimmer.fromColors(
                                    enabled: true,
                                    baseColor: Colors.grey.withOpacity(0.3),
                                    highlightColor:
                                        Colors.grey.withOpacity(0.1),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                      child: Container(
                                        height: 280,
                                        width: screenSize!.width,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                    onPressed: () {
                                      // log('Path :- ${_videos[index].url}');
                                      // Do nothing on button press89+56230
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NewVideoPlay(
                                                    type: 'url',
                                                    pathh:
                                                        "${AppEndpoints.imgUrl}${widget.images[index].path}",
                                                  )));

                                      log("This is the url${AppEndpoints.imgUrl}${widget.images[index].path}");
                                    },
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 30,
                                    )),
                              ),
                            ),
                          ],
                        );
                }),
          ),
          Positioned(
            bottom: 10.0,
            // top: 0.0,
            // left: 0.0,
            // right: 0.0,
            child: DotsIndicator(
              dotsCount: widget.images.length,
              position: _currentIndex.toDouble(),
              decorator: DotsDecorator(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(20.0),
                // ),
                activeShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
                size: const Size(10.0, 10.0), // Inactive dot: short pill
                activeSize: const Size(24.0, 9), // Active dot: long pill
                color: const Color(0xffCCCCCC), // Inactive color
                activeColor: AppColors.white, // Active color
                spacing: const EdgeInsets.symmetric(horizontal: 6.0),
              ),
            ),
          ),
          Positioned(
              top: 10.0,
              // top: 0.0,
              // left: 0.0,
              right: 10.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.blackColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: getTextWidget(
                    title: ' ${_currentIndex + 1} / ${widget.images.length}',
                    textFontSize: AppFonts.size13,
                    textColor: AppColors.white,
                    textFontWeight: AppFonts.medium,
                  ),
                ),
              ))
        ],
      );
}
