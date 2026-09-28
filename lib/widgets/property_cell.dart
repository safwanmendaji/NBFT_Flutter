import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyHomeProperty extends StatefulWidget {
  final List<Media>? image;
  final String? name;
  final String? price;
  final String? squarefeet;
  final String? floor;
  final String? location;
  const MyHomeProperty(
      {super.key,
      this.image,
      this.name,
      this.price,
      this.squarefeet,
      this.floor,
      this.location});

  @override
  State<MyHomeProperty> createState() => _MyHomePropertyState();
}

class _MyHomePropertyState extends State<MyHomeProperty> {
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
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: SizedBox(
        // margin: const EdgeInsets.symmetric(vertical: 8),
        width: screenSize!.width,
        // decoration: BoxDecoration(
        //   color: AppColors.white,
        //   borderRadius: BorderRadius.circular(33),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.20), // Soft black shadow
        //       blurRadius: 5,
        //       spreadRadius: 1,
        //       offset: const Offset(0, 1), // Slight bottom offset
        //     ),
        //   ],
        // ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          // mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: widget.image!.first.type == "image"
                  ? CachedNetworkImage(
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 247,
                          width: screenSize!.width,
                          decoration: const BoxDecoration(color: Colors.grey),
                        ),
                      ),
                      imageUrl:
                          "${AppEndpoints.imgUrl}${widget.image!.first.path!}",
                      height: 247,
                      width: screenSize!.width,
                      fit: BoxFit.cover,
                    )
                  : FutureBuilder<Uint8List?>(
                      future: generateThumbnail(
                          "${AppEndpoints.imgUrl}${widget.image!.first.path!}"),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return Stack(
                            children: [
                              Image.memory(
                                snapshot.data!,
                                height: 247,
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
                              height: 247,
                              width: screenSize!.width,
                              color: Colors.grey,
                            ),
                          );
                        }
                      },
                    ),
            ),
            Positioned(
                child: Container(
              height: 75,
              width: screenSize!.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: const Color(0x00000000).withValues(alpha: 0.19),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 16.0, bottom: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  // mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          AppIcons.icRuppee,
                          height: 18,
                          width: 18,
                          color: AppColors.white,
                          fit: BoxFit.cover,
                        ),
                        getTextWidget(
                            title:
                                "${NumberFormat.decimalPattern('en_IN').format(int.tryParse(widget.price?.toString() ?? '0') ?? 0)}/-",
                            textFontSize: AppFonts.size20,
                            textFontWeight: AppFonts.bold,
                            textColor: AppColors.white),
                      ],
                    ),
                    const SizedBox(
                      width: 11.0,
                    ),
                    Container(
                      height: 45,
                      width: 1,
                      decoration: const BoxDecoration(color: AppColors.white),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: screenSize!.width - 300,
                            child: getTextWidget(
                                title: widget.location!,
                                maxLines: 1,
                                textFontSize: AppFonts.size12,
                                textFontWeight: AppFonts.bold,
                                textColor: AppColors.white),
                          ),
                          getTextWidget(
                              title: widget.name!,
                              maxLines: 1,
                              textFontSize: AppFonts.size12,
                              textFontWeight: AppFonts.bold,
                              textColor: AppColors.white),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 15.0,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 6.0,
                                width: 6.0,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white),
                              ),
                              const SizedBox(
                                width: 7.0,
                              ),
                              getTextWidget(
                                  title: "${widget.squarefeet!} Sqft",
                                  maxLines: 1,
                                  textFontSize: AppFonts.size12,
                                  textFontWeight: AppFonts.bold,
                                  textColor: AppColors.white),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                height: 6.0,
                                width: 6.0,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white),
                              ),
                              const SizedBox(
                                width: 7.0,
                              ),
                              SizedBox(
                                width: screenSize!.width - 322,
                                child: getTextWidget(
                                    title: widget.floor!,
                                    maxLines: 1,
                                    textFontSize: AppFonts.size12,
                                    textFontWeight: AppFonts.bold,
                                    textColor: AppColors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  //  Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             getTextWidget(
  //               title: widget.name!,
  //               maxLines: 2,
  //               textFontWeight: AppFonts.medium,
  //               textColor: const Color(0XFF353535),
  //             ),
  //             const SizedBox(height: 6.0),
  //             Row(
  //               children: [
  //                 getTextWidget(
  //                   title: '${widget.price}/-',
  //                   textFontSize: AppFonts.size20,
  //                   textFontWeight: AppFonts.bold,
  //                 ),
  //                 const SizedBox(width: 14.0),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       getTextWidget(
  //                         title: "${widget.squarefeet}",
  //                         maxLines: 1,
  //                         textFontSize: AppFonts.size12,
  //                         textFontWeight: AppFonts.bold,
  //                         textColor: const Color(0XFF686868),
  //                       ),
  //                       getTextWidget(
  //                         title: widget.floor!,
  //                         textFontSize: AppFonts.size12,
  //                         textFontWeight: AppFonts.bold,
  //                         maxLines: 1,
  //                         textColor: const Color(0XFF686868),
  //                       ),
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //             const SizedBox(height: 6),
  //             Row(
  //               children: [
  //                 Image.asset(
  //                   AppIcons.icLocation,
  //                   height: 15,
  //                   width: 15,
  //                   fit: BoxFit.cover,
  //                 ),
  //                 const SizedBox(width: 5.0),
  //                 Expanded(
  //                   child: getTextWidget(
  //                     title: widget.location!,
  //                     textFontSize: AppFonts.size12,
  //                     maxLines: 3,
  //                     textFontWeight: AppFonts.bold,
  //                     textColor: const Color(0XFF686868),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       )
}
