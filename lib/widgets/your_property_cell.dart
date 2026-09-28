import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
// import 'package:flutter_nobrokeragefortenants/screens/add_property/property_form.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
 import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:shimmer/shimmer.dart';

 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/screens/customer_details/customer_details.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

 import 'package:flutter_nobrokeragefortenants/screens/add_property/property_form.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/video_player_widget.dart';

class MyYourPropertyWidget extends StatefulWidget {
  final List<Data> propertyData;
  final String propertyId;
  final int index;
  final List<Media>? propertyimage;
  final String? propertyname;
  final String? propertyprice;
  final String? propertysquarefeet;
  final String? propertyfloor;
  final String? propertydescription;
  final String? propertylocation;
  final String? propertyresidence;
  final VoidCallback? onRefresh;

  const MyYourPropertyWidget({
    super.key,
    this.propertyimage,
    this.onRefresh,
    this.propertyresidence,
    this.propertyname,
    this.propertydescription,
    this.propertyprice,
    this.propertysquarefeet,
    this.propertyfloor,
    this.propertylocation,
    required this.propertyId,
    required this.index,
    required this.propertyData,
  });

  @override
  State<MyYourPropertyWidget> createState() => _MyYourPropertyWidgetState();
}

class _MyYourPropertyWidgetState extends State<MyYourPropertyWidget> {
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
    getScreenSize(context);
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 13.0),
        child: Container(
          height: 300,
          child: Stack(
            // alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: widget.propertyimage!.first.type == "image"
                    ? CachedNetworkImage(
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 191,
                            decoration: const BoxDecoration(color: Colors.grey),
                          ),
                        ),
                        imageUrl:
                            "${AppEndpoints.imgUrl}${widget.propertyimage!.first.path!}",
                        height: 191,
                        width: screenSize!.width,
                        fit: BoxFit.cover,
                      )
                    : FutureBuilder<Uint8List?>(
                        future: generateThumbnail(
                            "${AppEndpoints.imgUrl}${widget.propertyimage!.first.path!}"),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.hasData) {
                            return Stack(
                              children: [
                                Image.memory(
                                  snapshot.data!,
                                  height: 191,
                                  width: screenSize!.width,
                                  fit: BoxFit.cover,
                                ),
                                // Positioned.fill(
                                //   child: Align(
                                //     alignment: Alignment.center,
                                //     child: IconButton(
                                //       onPressed: () {
                                //         Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //             builder: (context) => NewVideoPlay(
                                //               type: 'url',
                                //               pathh:
                                //                   "${AppEndpoints.imgUrl}${widget.propertyimage!.first.path!}",
                                //             ),
                                //           ),
                                //         );

                                //         log("This is the url ${AppEndpoints.imgUrl}${widget.propertyimage!.first.path!}");
                                //       },
                                //       icon: const Icon(
                                //         Icons.play_circle_fill,
                                //         size: 48,
                                //         color: Colors.white,
                                //       ),
                                //     ),
                                //   ),
                                // )
                              ],
                            );
                          } else {
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 191,
                                width: screenSize!.width,
                                color: Colors.grey,
                              ),
                            );
                          }
                        },
                      ),
              ),
              Positioned(
                top: 130,
                left: 25,
                right: 25,
                // bottom: 10,
                child: Container(
                  width: screenSize!.width,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.8),
                    border: Border.all(width: 2, color: AppColors.secondary),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 5.0, bottom: 15.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            getTextWidget(
                                title:
                                    '${widget.propertyData[widget.index].size} sqft',
                                textFontSize: AppFonts.size12,
                                textFontWeight: AppFonts.bold,
                                maxLines: 1,
                                textColor: AppColors.white),
                            const Spacer(),
                            getTextWidget(
                                title: widget.propertyresidence!,
                                textFontSize: AppFonts.size12,
                                textFontWeight: AppFonts.bold,
                                maxLines: 2,
                                textColor: AppColors.white),
                          ],
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          width: screenSize!.width,
                          child: getTextWidget(
                            title: widget.propertyname!,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            textFontSize: AppFonts.size15,
                            textFontWeight: AppFonts.semiBold,
                            textColor: AppColors.white,
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          height: 1,
                          width: screenSize!.width / 4,
                          decoration:
                              const BoxDecoration(color: AppColors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, top: 10),
                        child: Row(
                          children: [
                            Image.asset(
                              AppIcons.icLocation,
                              height: 15,
                              width: 15,
                              fit: BoxFit.cover,
                              color: AppColors.white,
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                            SizedBox(
                              width: screenSize!.width - 115,
                              child: getTextWidget(
                                  title: widget.propertylocation!,
                                  textFontSize: AppFonts.size10,
                                  maxLines: 1,
                                  textFontWeight: AppFonts.bold,
                                  textColor: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, top: 5.0),
                        child: getTextWidget(
                            title: '${widget.propertyfloor}',
                            textFontSize: AppFonts.size10,
                            textFontWeight: AppFonts.bold,
                            maxLines: 2,
                            textColor: AppColors.white),
                      ),
                      const SizedBox(
                        height: 3.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0, bottom: 10.0),
                        child: SizedBox(
                          width: screenSize!.width,
                          child: getTextWidget(
                              maxLines: 1,
                              title: widget.propertydescription!,
                              textFontSize: AppFonts.size10,
                              textFontWeight: AppFonts.bold,
                              textColor: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 255,
                left: 25,
                right: 25,

                // bottom: 10,
                child: Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xffB09676),
                        Color(0xff4A3F32),
                      ]),
                      // color: AppColors.secondary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 5.0, top: 5.0),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            final property = widget.propertyData[widget.index];

                            log('Navigating to Edit Property with the following data:');
                            log('Type: ${property.type}');
                            log('Location (Address): ${property.location}');
                            log('Description: ${property.description}');
                            log('Title (Name): ${property.title}');
                            log('Pincode: "" (empty)');
                            log('Price: ${property.price}');
                            log('Size Type: ${property.sizeType}');
                            log('Area: ${property.area}');
                            log('City: "" (empty)');
                            log('Floor: ${property.floor}');
                            log('Format: ${property.format}');
                            log('Furnished: ${property.furnished}');
                            log('State: "" (empty)');
                            log('SizeType (again): ${property.sizeType}');
                            log("Imaegs and video ${widget.propertyData[widget.index].media}");
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyAddPropertyForm(
                                          propertyId: widget
                                              .propertyData[widget.index].sId,
                                          media: widget
                                              .propertyData[widget.index].media,
                                          type: widget
                                              .propertyData[widget.index].type!,
                                          from: "Edit",

                                          propertyaddress: widget
                                              .propertyData[widget.index]
                                              .location,
                                          propertydescription: widget
                                              .propertyData[widget.index]
                                              .description,
                                          propertyname: widget
                                              .propertyData[widget.index].title,
                                          propertypincode: "380001",
                                          propertyprice: widget
                                              .propertyData[widget.index].price!
                                              .toString(),
                                          propertysize: widget
                                              .propertyData[widget.index].size,
                                          selectArea: widget
                                              .propertyData[widget.index].area,
                                          selectCity: "Ahmedabad",
                                          selectFloor: widget
                                              .propertyData[widget.index].floor,
                                          selectFormat: widget
                                              .propertyData[widget.index]
                                              .format,
                                          selectFurnished: widget
                                              .propertyData[widget.index]
                                              .furnished,
                                          // selectNegotiation: "",
                                          selectSizetype: widget
                                              .propertyData[widget.index]
                                              .sizeType,
                                          selectState: "Gujarat",
                                          // selectedCategory: widget
                                          //     .propertyData[widget.index].category,
                                        )));

                            // This is the key part:
                            if (result == true && widget.onRefresh != null) {
                              widget.onRefresh!(); // trigger parent API refresh
                            }
                          },
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppIcons.icEditOutline,
                                height: 15,
                                width: 15,
                                color: AppColors.blackColor,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(
                                width: 3.0,
                              ),
                              getTextWidget(
                                  title: 'Edit Property',
                                  textFontWeight: AppFonts.bold,
                                  textFontSize: AppFonts.size13,
                                  textColor: AppColors.blackColor)
                            ],
                          ),
                        ),

                        Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AppIcons.icEye,
                              height: 15,
                              width: 15,
                              color: AppColors.blackColor,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(
                              width: 3.0,
                            ),
                            getTextWidget(
                                title: 'View Details',
                                textFontWeight: AppFonts.bold,
                                textFontSize: AppFonts.size13,
                                textColor: AppColors.blackColor)
                          ],
                        ),

                        // GestureDetector(
                        //   onTap: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) => MyCustomerDetails(
                        //                   propertyId: widget.propertyId,
                        //                 )));
                        //   },
                        //   child: Container(
                        //       width: screenSize!.width / 2.5,
                        //       decoration: BoxDecoration(
                        //           borderRadius: BorderRadius.circular(16),
                        //           color: AppColors.primary),
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             left: 12.0,
                        //             right: 12.0,
                        //             top: 6.0,
                        //             bottom: 6.0),
                        //         child: getTextWidget(
                        //             textAlign: TextAlign.center,
                        //             title: 'Customer Details',
                        //             maxLines: 1,
                        //             textFontWeight: AppFonts.bold,
                        //             textColor: AppColors.white),
                        //       )),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  top: 120,
                  right: 120,
                  left: 120,
                  child: Container(
                    clipBehavior: Clip.none,
                    // width: screenSize!.width / 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.secondary,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.white.withOpacity(0.35), // Shadow color
                            offset: const Offset(
                                0, 3), // Horizontal and vertical offset
                            blurRadius: 6, // How much the shadow should blur
                            spreadRadius: 1, // How far the shadow spreads
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 11.0,
                        right: 11.0,
                        top: 4.0,
                        bottom: 4.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(
                            AppIcons.icRuppee,
                            height: 10,
                            width: 10,
                            fit: BoxFit.cover,
                          ),
                          // Spacer(),
                          getTextWidget(
                              title: NumberFormat.decimalPattern('en_IN')
                                  .format(int.tryParse(
                                          widget.propertyprice?.toString() ??
                                              '0') ??
                                      0),
                              textFontSize: AppFonts.size12,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              textFontWeight: AppFonts.bold,
                              textColor: AppColors.blackColor),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      );
    });
  }
}




    // Padding(
          //   padding: const EdgeInsets.only(top: 18.0, left: 1.0, right: 11.0),
          //   child: Container(
          //     // color: AppColors.accountoption,
          //     child: Row(
          //       children: [
          //         SizedBox(
          //           width: screenSize!.width - 185,
          //           child: getTextWidget(
          //               title: widget.propertyname!,
          //               textFontSize: AppFonts.size17,
          //               maxLines: 2,
          //               textFontWeight: AppFonts.bold),
          //         ),
          //         const Spacer(),
          //         getTextWidget(
          //           title: '${widget.propertyprice!}/-',
          //           maxLines: 1,
          //           textFontSize: AppFonts.size20,
          //           textFontWeight: AppFonts.bold,
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          // Container(
          //   // color: AppColors.blackColor,
          //   child: SizedBox(
          //     width: screenSize!.width,
          //     child: Row(
          //       // mainAxisAlignment: MainAxisAlignment.spaceAround,
          //       children: [
          //         getTextWidget(
          //             title: '${widget.propertysquarefeet}',
          //             textFontSize: AppFonts.size12,
          //             textFontWeight: AppFonts.bold,
          //             maxLines: 2,
          //             textColor: AppColors.darkgreycolor),
          //         const Spacer(),
          //         Padding(
          //           padding: const EdgeInsets.only(left: 32.0),
          //           child: Row(
          //             children: [
          //               Image.asset(
          //                 AppIcons.icLocation,
          //                 height: 15,
          //                 width: 15,
          //                 fit: BoxFit.cover,
          //               ),
          //               const SizedBox(
          //                 width: 5.0,
          //               ),
          //               getTextWidget(
          //                   title: widget.propertylocation!,
          //                   textFontSize: AppFonts.size12,
          //                   maxLines: 2,
          //                   textFontWeight: AppFonts.bold,
          //                   textColor: AppColors.darkgreycolor),
          //             ],
          //           ),
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(
          //   height: 9.0,
          // ),
          // getTextWidget(
          //     title: '${widget.propertyfloor}',
          //     textFontSize: AppFonts.size12,
          //     textFontWeight: AppFonts.bold,
          //     maxLines: 2,
          //     textColor: AppColors.darkgreycolor),
          // const SizedBox(
          //   height: 9.0,
          // ),
          // getTextWidget(
          //     title: widget.propertydescription!,
          //     textFontSize: AppFonts.size13,
          //     textFontWeight: AppFonts.regular,
          //     textColor: AppColors.darkgreycolor),
          // const SizedBox(
          //   height: 7.0,
          // ),

          // Row(
          //   children: [
          //     getTextWidget(
          //       title: 'View Details',
          //       textFontSize: AppFonts.size12,
          //       textColor: AppColors.primaryblue,
          //     ),
          //     Padding(
          //       padding: const EdgeInsets.only(top: 2.0, left: 1.0),
          //       child: Image.asset(
          //         AppIcons.icArrowline,
          //         height: 17,
          //         width: 17,
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //     const Spacer(),
          //     getTextWidget(
          //         title: widget.propertyresidence!,
          //         // textFontSize: AppFonts.size12,
          //         textFontWeight: AppFonts.bold,
          //         textColor: AppColors.darkgreycolor),
          //   ],
          // ),
          // const SizedBox(
          //   height: 23,
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     GestureDetector(
          //       behavior: HitTestBehavior.translucent,
          //       onTap: () async {
          //         final property = widget.propertyData[widget.index];

          //         log('Navigating to Edit Property with the following data:');
          //         log('Type: ${property.type}');
          //         log('Location (Address): ${property.location}');
          //         log('Description: ${property.description}');
          //         log('Title (Name): ${property.title}');
          //         log('Pincode: "" (empty)');
          //         log('Price: ${property.price}');
          //         log('Size Type: ${property.sizeType}');
          //         log('Area: ${property.area}');
          //         log('City: "" (empty)');
          //         log('Floor: ${property.floor}');
          //         log('Format: ${property.format}');
          //         log('Furnished: ${property.furnished}');
          //         log('State: "" (empty)');
          //         log('SizeType (again): ${property.sizeType}');
          //         log("Imaegs and video ${widget.propertyData[widget.index].media}");
          //         final result = await Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => MyAddPropertyForm(
          //                       propertyId:
          //                           widget.propertyData[widget.index].sId,
          //                       media: widget.propertyData[widget.index].media,
          //                       type: widget.propertyData[widget.index].type!,
          //                       from: "Edit",

          //                       propertyaddress:
          //                           widget.propertyData[widget.index].location,
          //                       propertydescription: widget
          //                           .propertyData[widget.index].description,
          //                       propertyname:
          //                           widget.propertyData[widget.index].title,
          //                       propertypincode: "380001",
          //                       propertyprice: widget
          //                           .propertyData[widget.index].price!
          //                           .toString(),
          //                       propertysize:
          //                           widget.propertyData[widget.index].size,
          //                       selectArea:
          //                           widget.propertyData[widget.index].area,
          //                       selectCity: "Ahmedabad",
          //                       selectFloor:
          //                           widget.propertyData[widget.index].floor,
          //                       selectFormat:
          //                           widget.propertyData[widget.index].format,
          //                       selectFurnished:
          //                           widget.propertyData[widget.index].furnished,
          //                       // selectNegotiation: "",
          //                       selectSizetype:
          //                           widget.propertyData[widget.index].sizeType,
          //                       selectState: "Gujarat",
          //                       // selectedCategory: widget
          //                       //     .propertyData[widget.index].category,
          //                     )));

          //         // This is the key part:
          //         if (result == true && widget.onRefresh != null) {
          //           widget.onRefresh!(); // trigger parent API refresh
          //         }
          //       },
          //       child: Container(
          //           width: screenSize!.width / 2.5,
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(16),
          //               color: AppColors.primary),
          //           child: Padding(
          //             padding: const EdgeInsets.only(
          //                 left: 9.0, right: 18.0, top: 6.0, bottom: 6.0),
          //             child: Row(
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Image.asset(
          //                   AppIcons.icEditOutline,
          //                   height: 18,
          //                   width: 18,
          //                   fit: BoxFit.cover,
          //                 ),
          //                 const SizedBox(
          //                   width: 3.0,
          //                 ),
          //                 getTextWidget(
          //                     title: 'Edit Property',
          //                     textFontWeight: AppFonts.bold,
          //                     textColor: AppColors.white)
          //               ],
          //             ),
          //           )),
          //     ),
          //     GestureDetector(
          //       onTap: () {
          //         Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //                 builder: (context) => MyCustomerDetails(
          //                       propertyId: widget.propertyId,
          //                     )));
          //       },
          //       child: Container(
          //           width: screenSize!.width / 2.5,
          //           decoration: BoxDecoration(
          //               borderRadius: BorderRadius.circular(16),
          //               color: AppColors.primary),
          //           child: Padding(
          //             padding: const EdgeInsets.only(
          //                 left: 12.0, right: 12.0, top: 6.0, bottom: 6.0),
          //             child: getTextWidget(
          //                 textAlign: TextAlign.center,
          //                 title: 'Customer Details',
          //                 maxLines: 1,
          //                 textFontWeight: AppFonts.bold,
          //                 textColor: AppColors.white),
          //           )),
          //     ),
          //   ],
          // )
      
      