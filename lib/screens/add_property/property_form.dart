import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_nobrokeragefortenants/screens/properties/properties_screen.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_bottom_tab.dart';
import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/extensions/string_extension.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/widgets/custom_dropdown_cell.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:video_player/video_player.dart';

import 'package:flutter_nobrokeragefortenants/core/dialogs/customize_alert_dialog.dart';
import 'package:flutter_nobrokeragefortenants/models/area/area_model.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:flutter_nobrokeragefortenants/widgets/video_player_widget.dart';

// enum MediaTypeEnum { image, video }

// class MediaFile {
//   final MediaTypeEnum type;
//   final File file;
//   final String? url; // optional: for uploaded media

//   MediaFile({
//     required this.type,
//     required this.file,
//     this.url,
//   });
// }

class MyAddPropertyForm extends StatefulWidget {
  final String from;
  final String type;
  final String? category;
  final List<Media>? media;
  final String? propertyId;
  final String? propertyname;
  final String? propertyaddress;
  final String? propertysize;
  final String? propertypincode;
  final String? propertydescription;
  final String? propertyprice;
  // final String? selectedCategory;
  final String? selectFormat;
  final String? selectFurnished;
  // final String? selectNegotiation;
  final String? selectState;
  final String? selectCity;
  final String? selectArea;
  final String? selectSizetype;
  final String? selectFloor;

  const MyAddPropertyForm({
    super.key,
    required this.from,
    required this.type,
    this.category,
    this.propertyId,
    this.propertyname,
    this.propertyaddress,
    this.propertysize,
    this.propertypincode,
    this.propertydescription,
    this.propertyprice,
    // this.selectedCategory,
    this.selectFormat,
    this.selectFurnished,
    // this.selectNegotiation,
    this.selectState,
    this.selectCity,
    this.selectArea,
    this.selectSizetype,
    this.selectFloor,
    this.media,
  });

  @override
  State<MyAddPropertyForm> createState() => _MyAddPropertyFormState();
}

class _MyAddPropertyFormState extends State<MyAddPropertyForm> {
  int _currentSection = 0;

  // final _scrollController = ScrollController();
  final _formkey = GlobalKey<FormState>();
  final _pricecontroller = TextEditingController();
  final _sizecontroller = TextEditingController();
  final _schemecontroller = TextEditingController();
  final _descriptioncontroller = TextEditingController();
  final _addresscontroller = TextEditingController();
  final _pinciodecontroller = TextEditingController();

  // String? selectedCategory;
  String? selectFormat;
  String? selectFurnished;
  // String? selectNegotiation;
  String? selectState;
  String? selectCity;
  String? selectArea;
  String? selectSizetype;
  String? selectFloor;
  String? selecttype;
  String? selectedCategory;
  File? _selectedPropertyImage;

  // List imagelist = [];
  List<VideoPlayerController> controllers = [];

  final picker = ImagePicker();
  List<String> removedMediaPaths = [];
  List<Areas> area = [];
  List<Media> mediaFiles = [];

  Future<Uint8List?> generateThumbnail(String videoPath) async {
    try {
      final uint8List = await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
        maxHeight: 400,
        maxWidth: 400,
        quality: 50,
      );
      //return uint8List;
      return Uint8List.fromList(uint8List!); // Convert List<int> to Uint8List
    } catch (e) {
      log('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<Uint8List?> generateLocalThumbnail(String videoPath) async {
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoPath,
        // videofile.path,
        imageFormat: ImageFormat.PNG,
        maxWidth:
            128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
        quality: 25,
      );
      //return uint8List;
      return Uint8List.fromList(uint8list!); // Convert List<int> to Uint8List
    } catch (e) {
      log('Error in generating  Local thumbnail: $e');
      return null;
    }
  }

  _updatePropertyapi() async {
    var data = FormData.fromMap({
      "schemeName": "",
      'title': _schemecontroller.text.toString(),
      'price': _pricecontroller.text.toString(),
      'area': selectArea.toString(),
      'floor': selectFloor.toString(),
      'size': _sizecontroller.text.toString(),
      'location': _addresscontroller.text.toString(),
      'description': _descriptioncontroller.text.toString(),
      "pincode": int.tryParse(_pinciodecontroller.text),
      'type': widget.type,
      'category': selectedCategory ?? widget.category ?? 'Rent',
      'format': selectFormat.toString(),
      'sizeType': selectSizetype.toString(),
      'removeMedia': removedMediaPaths,
      'furnished': selectFurnished.toString(),
    });
    for (var file in mediaFiles) {
      // Skip media that isn't newly added from local storage
      if (file.file == null) continue;

      String filePath = file.file!.path;
      String fileName = filePath.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      MediaType? mediaType;
      String fieldKey;

      // Determine file type and appropriate field name
      if (['jpg', 'jpeg'].contains(fileExtension)) {
        mediaType = MediaType('image', 'jpeg');
        fieldKey = 'images';
      } else if (fileExtension == 'png') {
        mediaType = MediaType('image', 'png');
        fieldKey = 'images';
      } else if (fileExtension == 'mp4') {
        mediaType = MediaType('video', 'mp4');
        fieldKey = 'videos';
      } else {
        // Skip unsupported file types
        continue;
      }

      data.files.add(
        MapEntry(
          fieldKey,
          await MultipartFile.fromFile(
            filePath,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    for (var field in data.fields) {
      log('Field -> ${field.key}: ${field.value}');
    }

    // ✅ Log files
    for (var file in data.files) {
      var multipart = file.value;
      log('File -> ${file.key}: ${multipart.filename}');
    }

    // data.files.add(MapEntry("cat_photo", propertyimage));
    await Propertyapis.updatepropertydetail(
          data: data,
          context: context,
          propertyId: widget.propertyId!,
        )
        .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            log("Api Success");
            Fluttertoast.showToast(msg: "Property Update Successfully");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PrimaryBottomTab()),
              (r) => false,
            );
          } else {
            log("failed");
            customizedAlertDialogue(
              context: context,
              desc: "${response.message}",
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stackTrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  _addPropertyapi() async {
    var data = FormData.fromMap({
      "schemeName": "",
      'title': _schemecontroller.text.toString(),
      'price': _pricecontroller.text.toString(),
      'area': selectArea.toString(),
      'floor': selectFloor.toString(),
      'size': _sizecontroller.text.toString(),
      'location': _addresscontroller.text.toString(),
      'description': _descriptioncontroller.text.toString(),
      "pincode": int.tryParse(_pinciodecontroller.text),
      'type': widget.type,
      'category': selectedCategory ?? widget.category ?? 'Rent',
      'format': selectFormat.toString(),
      'sizeType': selectSizetype.toString(),
      'furnished': selectFurnished.toString(),
    });

    for (var file in mediaFiles) {
      String filePath = file.file!.path;
      String fileName = filePath.split('/').last;
      String fileExtension = fileName.split('.').last.toLowerCase();

      MediaType? mediaType;
      String fieldKey;

      // Determine file type and appropriate field name
      if (['jpg', 'jpeg'].contains(fileExtension)) {
        mediaType = MediaType('image', 'jpeg');
        fieldKey = 'images';
      } else if (fileExtension == 'png') {
        mediaType = MediaType('image', 'png');
        fieldKey = 'images';
      } else if (fileExtension == 'mp4') {
        mediaType = MediaType('video', 'mp4');
        fieldKey = 'videos';
      } else {
        // Skip unsupported file types or handle as needed
        continue;
      }

      data.files.add(
        MapEntry(
          fieldKey,
          await MultipartFile.fromFile(
            filePath,
            filename: fileName,
            contentType: mediaType,
          ),
        ),
      );
    }

    for (var field in data.fields) {
      log('Field -> ${field.key}: ${field.value}');
    }

    for (var file in data.files) {
      var multipart = file.value;
      log('File -> ${file.key}: ${multipart.filename}');
    }

    // data.files.add(MapEntry("cat_photo", propertyimage));
    await Propertyapis.addpropertydetail(data: data, context: context)
        .then((response) {
          if (response.statusCode == 200 || response.statusCode == 201) {
            log("Api Success");
            Fluttertoast.showToast(msg: "Property Added Successfully");
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const PrimaryBottomTab()),
              (r) => false,
            );
            // Navigator.pop(context);
          } else {
            log("failed");
            customizedAlertDialogue(
              context: context,
              desc: "${response.message}",
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stackTrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  _getAreaApi() async {
    await Propertyapis.getArea(
          params: {"page": "1", "size": "10", "search": ""},
          context: context,
        )
        .then((response) {
          if (response.message == "Area list fetched successfully") {
            log("Api Success ");
            area = response.areas!;
            setState(() {});
          } else {
            log("failed ${response.message}");
            customizedAlertDialogue(
              context: context,
              desc: "${response.message}",
              onPressed: () {
                Navigator.pop(context);
              },
            ).show();
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stackTrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }
  // late ScrollController _scrollController;
  // double _opacity = 1.0;

  // void _handleScroll() {
  //   double offset = _scrollController.offset;
  //   // Fade between 0 to 200 scroll range
  //   double newOpacity = (1 - (offset / 200)).clamp(0.0, 1.0);
  //   if (newOpacity != _opacity) {
  //     setState(() {
  //       _opacity = newOpacity;
  //     });
  //   }
  // }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    Future.delayed(Durations.medium2, () {
      _getAreaApi();
    });
    selectedCategory = widget.category ?? 'Rent';
    if (widget.from == "Edit") {
      // _scrollController = ScrollController();
      // _scrollController.addListener(_handleScroll);
      mediaFiles =
          widget.media!.map((media) {
            // If enumtype is already set, retain it
            if (media.enumtype != null) return media;

            // Otherwise, determine type based on file extension
            final path = media.path ?? media.file?.path ?? '';
            if (path.toLowerCase().endsWith('.jpg') ||
                path.toLowerCase().endsWith('.jpeg') ||
                path.toLowerCase().endsWith('.png') ||
                path.toLowerCase().endsWith('.gif') ||
                path.toLowerCase().endsWith('.webp')) {
              media.enumtype = MediaTypeEnum.image;
            } else if (path.toLowerCase().endsWith('.mp4') ||
                path.toLowerCase().endsWith('.mov') ||
                path.toLowerCase().endsWith('.avi') ||
                path.toLowerCase().endsWith('.mkv')) {
              media.enumtype = MediaTypeEnum.video;
            }

            return media;
          }).toList();
      _pricecontroller.text = widget.propertyprice.toString();
      _sizecontroller.text = widget.propertysize.toString();
      _schemecontroller.text = widget.propertyname.toString();
      _descriptioncontroller.text = widget.propertydescription.toString();
      _addresscontroller.text = widget.propertyaddress.toString();
      _pinciodecontroller.text = widget.propertypincode.toString();
      // selectedCategory = widget.selectedCategory;
      selectFormat = widget.selectFormat;
      selectFurnished = widget.selectFurnished;
      // selectNegotiation = widget.selectNegotiation ?? "Yes";
      selectState = widget.selectState ?? 'Gujarat';
      selectCity = widget.selectCity ?? "Ahmedabad";
      selectArea = widget.selectArea;
      selectSizetype = widget.selectSizetype;
      selectFloor = widget.selectFloor;
    }
    setState(() {});
  }

  Widget tick(Color circlecolor, bool isChecked) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: circlecolor,
        border:
            isChecked == true
                ? Border.all(width: 2, color: const Color(0xFFB1B9C7))
                : null,
      ),
    );
  }

  Widget line(Color linecolor) {
    return Container(
      color: linecolor,
      height: 3.0,
      width: screenSize!.width / 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MyCustomHeaderLogo(),
          MyCustomHeader(
            title: widget.from == "Edit" ? 'Update Property' : 'Add Property',
            isBackButton: true,
          ),

          Container(
            // height: 80,
            // color: AppColors.white,
            // width: screenSize!.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 16.0,
                    left: 36,
                    right: 36,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      tick(
                        _currentSection >= 0
                            ? AppColors.secondary
                            : AppColors.white,
                        _currentSection > 0,
                      ),
                      line(
                        _currentSection >= 1
                            ? AppColors.secondary
                            : Colors.white,
                      ),
                      tick(
                        _currentSection >= 1
                            ? AppColors.secondary
                            : AppColors.white,
                        _currentSection > 1,
                      ),
                      line(
                        _currentSection >= 2
                            ? AppColors.secondary
                            : Colors.white,
                      ),
                      tick(
                        _currentSection >= 2
                            ? AppColors.secondary
                            : AppColors.white,
                        false,
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       getTextWidget(
                //         title: 'Details',
                //       ),
                //       getTextWidget(
                //         title: 'Area',
                //       ),
                //       getTextWidget(
                //         title: 'Requirements ',
                //       )
                //     ],
                //   ),
                // )
              ],
            ),
          ),

          // Padding(
          //   padding: const EdgeInsets.only(top: 5.0, left: 35.0, right: 34.0),
          //   child: getTextWidget(
          //     textAlign: TextAlign.center,
          //     title: 'Want to rent out your property?',
          //     textFontSize: AppFonts.size20,
          //     textFontWeight: AppFonts.bold,
          //   ),
          // ),
          // const SizedBox(
          //   height: 5,
          // ),
          // Padding(
          //   padding: const EdgeInsets.only(left: 35.0, right: 35.0),
          //   child: getTextWidget(
          //     textAlign: TextAlign.center,
          //     title: 'Details about property you want?',
          //     textFontSize: AppFonts.size20,
          //   ),
          // ),
          Expanded(child: SingleChildScrollView(child: _getForm())),
        ],
      ),
      bottomNavigationBar: Container(child: _getButton()),
    );
  }

  _getForm() => Padding(
    padding: const EdgeInsets.only(left: 32.0, right: 28.0, top: 20.0),
    child: Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Section 0: Details
          if (_currentSection == 0) ...[
            getTextWidget(
              title: 'Details',
              textFontSize: AppFonts.size22,
              textColor: AppColors.white,
              textFontWeight: FontWeight.bold,
            ),
            Container(
              height: 3,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            getTextWidget(
              title: 'Property Images & Videos',
              textColor: AppColors.white,
              textFontWeight: AppFonts.semiBold,
              textFontSize: AppFonts.size18,
            ),
            // _buildImagePicker(),
            const SizedBox(height: 9),

            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                // _showBottomSheet(0);
                _showBottomMediaPicker();
              },
              child: Container(
                width: screenSize!.width,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(width: 2, color: AppColors.primary),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                  child:
                      _selectedPropertyImage != null
                          ? Image.file(
                            _selectedPropertyImage!,
                            height: 100,
                            width: screenSize!.width,
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppIcons.icUpload,
                                height: 44.44,
                                width: 44.44,
                                fit: BoxFit.cover,
                              ),
                              getTextWidget(
                                title: 'Select Images',
                                textFontSize: AppFonts.size18,
                                textColor: AppColors.primary,
                              ),
                            ],
                          ),
                ),
              ),
            ),
            _getMediaList(),
            _getSchemename(),
            _getPropertyDescription(),
          ],

          /// Section 1: Area
          if (_currentSection == 1) ...[
            getTextWidget(
              title: 'Area',
              textFontSize: AppFonts.size22,
              textColor: AppColors.white,
              textFontWeight: FontWeight.bold,
            ),
            Container(
              height: 3,
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            _getAddress(),
            _getPincode(),
            _getState(),
            _getCity(),
            _getArea(),
          ],

          /// Section 2: Requirements
          if (_currentSection == 2) ...[
            getTextWidget(
              title: 'Requirements',
              textFontSize: AppFonts.size22,
              textColor: AppColors.white,
              textFontWeight: FontWeight.bold,
            ),
            Container(
              height: 3,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 20),
            _getype(),
            _getFurnished(),
            _getFormat(),
            _getFloor(),
            _getSizeType(),
            _getSize(),
            _getPrice(),
          ],

          /// Button Row
        ],
      ),
    ),
  );

  // _getImageList() => imagelist == []
  //     ? null
  //     : Padding(
  //         padding: const EdgeInsets.only(top: 8.0),
  //         child: SizedBox(
  //           height: 70,
  //           child: ListView.builder(
  //               shrinkWrap: true,
  //               itemCount: imagelist.length,
  //               scrollDirection: Axis.horizontal,
  //               itemBuilder: (context, index) {
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 8.0),
  //                   child: Stack(
  //                     children: [
  //                       ClipRRect(
  //                         borderRadius: BorderRadius.circular(12),
  //                         child: Image.file(
  //                           imagelist[index],
  //                           height: 80,
  //                           width: 80,
  //                           fit: BoxFit.cover,
  //                         ),
  //                       ),
  //                       Positioned(
  //                           top: 1,
  //                           right: 1,
  //                           child: Container(
  //                             height: 25,
  //                             width: 25,
  //                             decoration: const BoxDecoration(
  //                                 color: AppColors.white,
  //                                 shape: BoxShape.circle),
  //                             child: IconButton(
  //                                 onPressed: () {
  //                                   imagelist.remove(imagelist[index]);
  //                                   setState(() {});
  //                                 },
  //                                 icon: Image.asset(
  //                                   AppIcons.icCross,
  //                                   height: 21,
  //                                   width: 21,
  //                                   fit: BoxFit.cover,
  //                                 )),
  //                           ))
  //                     ],
  //                   ),
  //                 );
  //               }),
  //         ),
  //       );

  // _getRangeSlider() => Padding(
  //       padding: const EdgeInsets.only(top: 15.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           getTextWidget(
  //             title: 'Price',
  //             textFontSize: AppFonts.size18,
  //           ),
  //           RangeSlider(
  //               values: _currentRangeValues,
  //               // padding: const EdgeInsets.only(top: 16.0, right: 16.0),
  //               activeColor: AppColors.primary,
  //               inactiveColor: AppColors.thirdwhite,

  //               // thumbColor: AppColors.primary,
  //               // value: priceRange,
  //               min: 1000.0,
  //               max: 50000.0,
  //               divisions: 1000, // Every 1,000
  //               labels: RangeLabels(
  //                 _currentRangeValues.start.round().toString(),
  //                 _currentRangeValues.end.round().toString(),
  //               ),
  //               onChanged: (RangeValues values) {
  //                 _currentRangeValues = values;

  //                 setState(() {});
  //               }),
  //         ],
  //       ),
  //     );

  _getButton() => Padding(
    padding: const EdgeInsets.only(
      left: 16.0,
      right: 16.0,
      top: 16.0,
      bottom: 32.0,
    ),
    child: CustomizedButton(
      title:
          widget.from == "Edit"
              ? _currentSection == 2
                  ? "Update Property"
                  : "Next"
              : _currentSection == 2
              ? "Add Property"
              : "Next",
      onTap: () async {
        if (_validateSection(_currentSection)) {
          if (_currentSection < 2) {
            setState(() {
              _currentSection++;
            });
          } else {
            // Final submission
            if (widget.from == "Edit") {
              await _updatePropertyapi();
            } else {
              await _addPropertyapi();
            }
          }
        }
      },
    ),
  );

  _getPrice() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Price',
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
          textFontSize: AppFonts.size18,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          controller: _pricecontroller,
          hintText: "25,000",
          inputFormatters: [LengthLimitingTextInputFormatter(7)],
          validation: (value) => value?.validateRequireField(context),
          keyboardType: TextInputType.number,
        ),
      ],
    ),
  );

  _getSize() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Size',
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
          textFontSize: AppFonts.size18,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          controller: _sizecontroller,
          hintText: "000",
          inputFormatters: [LengthLimitingTextInputFormatter(5)],
          validation: (value) => value?.validateRequireField(context),
          keyboardType: TextInputType.number,
        ),
      ],
    ),
  );

  _getAddress() => Padding(
    padding: const EdgeInsets.only(top: 6.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Address',
          textFontSize: AppFonts.size18,
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          maxline: 3,
          controller: _addresscontroller,
          validation: (value) => value?.validateRequireField(context),
          hintText: "Address",
          // keyboardType: TextInputType.number,
        ),
      ],
    ),
  );

  _getPropertyDescription() => Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Property Description',
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
          textFontSize: AppFonts.size18,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          controller: _descriptioncontroller,
          validation: (value) => value?.validateRequireField(context),
          hintText: "Property Description",
          maxline: 3,
        ),
      ],
    ),
  );

  _getSchemename() => Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Property Name',
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
          textFontSize: AppFonts.size18,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          controller: _schemecontroller,
          validation: (value) => value?.validateRequireField(context),
          hintText: "Property Name",
        ),
      ],
    ),
  );

  _getPincode() => Padding(
    padding: const EdgeInsets.only(top: 20.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getTextWidget(
          title: 'Pincode',
          textColor: AppColors.white,
          textFontWeight: AppFonts.semiBold,
          textFontSize: AppFonts.size18,
        ),
        const SizedBox(height: 9),
        PrimaryTextFeild(
          controller: _pinciodecontroller,
          validation: (value) => value?.validateRequireField(context),
          hintText: "For e.g. 380001",
          hintColor: AppColors.accountoption,
          keyboardType: TextInputType.number,
        ),
      ],
    ),
  );

  _getFloor() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: [
        "Top (Nineth and Above)",
        "Middle (Fourth to Nineth floor)",
        "Bottom (Ground to Fourth floor)",
      ],
      selecttext: "Select Floor.",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Floor",
      onChanged: (value) {
        selectFloor = value;
        setState(() {});
      },
      selectedValue: selectFloor,
    ),
  );

  _getSizeType() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["Sqft", "Vigha", "SqYard"],
      selecttext: "Select ",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Size Type",
      onChanged: (value) {
        selectSizetype = value;
        setState(() {});
      },
      selectedValue: selectSizetype,
    ),
  );

  // _getCategory() => Padding(
  //       padding: const EdgeInsets.only(top: 14.0),
  //       child: MyCustomizeDropdown(
  //         items: ["Buy", "Rent"],
  //         selecttext: "Select Buy or Rent",
  //         fontsize: AppFonts.size18,
  //         hintfontsize: AppFonts.size18,
  //         labelText: "Category",
  //         onChanged: (value) {
  //           selectedCategory = value;
  //           setState(() {});
  //         },
  //         selectedValue: selectedCategory,
  //       ),
  //     );

  _getFormat() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["1BHK", "2BHK", "3BHK", "4BHK"],
      selecttext: "Select 1BHK, 2BHK etc.",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Format",
      onChanged: (value) {
        selectFormat = value;
        setState(() {});
      },
      selectedValue: selectFormat,
    ),
  );
  _getFurnished() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["Fully", "Unfurnished", "Semi"],
      selecttext: "Select",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Furnished",
      onChanged: (value) {
        selectFurnished = value;
        setState(() {});
      },
      selectedValue: selectFurnished,
    ),
  );
  // _getnegotiable() => Padding(
  //       padding: const EdgeInsets.only(top: 14.0),
  //       child: MyCustomizeDropdown(
  //         items: ["Yes", "No"],
  //         selecttext: "Select Yes or No",
  //         fontsize: AppFonts.size18,
  //         hintfontsize: AppFonts.size18,
  //         labelText: "Is negotiable",
  //         onChanged: (value) {
  //           selectNegotiation = value;
  //           setState(() {});
  //         },
  //         selectedValue: selectNegotiation,
  //       ),
  //     );

  _getState() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["Gujarat", "Rajasthan"],
      selecttext: "Select",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "State",
      onChanged: (value) {
        selectState = value;
        setState(() {});
      },
      selectedValue: selectState,
    ),
  );
  _getCity() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["Gandhinagar", "Ahmedabad"],
      selecttext: "Select",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "City",
      onChanged: (value) {
        selectCity = value;
        setState(() {});
      },
      selectedValue: selectCity,
    ),
  );
  _getArea() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: area.map((areanme) => areanme.areaName!).toList(),
      selecttext: "Select",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Area",
      onChanged: (value) {
        selectArea = value;
        setState(() {});
      },
      selectedValue: selectArea,
    ),
  );

  _getype() => Padding(
    padding: const EdgeInsets.only(top: 14.0),
    child: MyCustomizeDropdown(
      items: ["Office", "Shop", "House", "Bunglow", "Flat"],
      selecttext: "Select Type",
      fontsize: AppFonts.size18,
      hintfontsize: AppFonts.size16,
      fontwieght: AppFonts.semiBold,
      fontColor: AppColors.white,
      labelText: "Type",
      onChanged: (value) {
        selecttype = value;
        setState(() {});
      },
      selectedValue: selecttype,
    ),
  );

  _validateSection(int step) {
    // Common form validation
    if (!_formkey.currentState!.validate()) {
      return false;
    }

    // Step-wise validation
    switch (step) {
      case 0: // Details Section
        if ((mediaFiles.isEmpty || mediaFiles == []) &&
            (controllers.isEmpty || controllers == [])) {
          Fluttertoast.showToast(
            msg: 'Please select at least one property image or video',
          );
          return false;
        }
        return true;

      case 1: // Area Section
        if (selectArea == null ||
            selectCity == null ||
            selectState == null ||
            _addresscontroller.text.isEmpty ||
            _pinciodecontroller.text.isEmpty) {
          Fluttertoast.showToast(msg: 'Please fill out all Area fields');
          return false;
        }
        return true;

      case 2: // Requirements Section
        if (selecttype == null ||
            selectFloor == null ||
            selectFormat == null ||
            selectFurnished == null ||
            selectSizetype == null ||
            _pricecontroller.text.isEmpty ||
            _sizecontroller.text.isEmpty) {
          Fluttertoast.showToast(
            msg: 'Please fill out all Requirements fields',
          );
          return false;
        }
        return true;

      default:
        return false;
    }
  }

  void _showBottomMediaPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text("Take Image From Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Pick Image From Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(ImageSource.gallery);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text("Record Video From Camera"),
                onTap: () {
                  Navigator.pop(context);
                  _getVideo(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text("Pick Video From Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _getVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // void _showBottomSheet(int index) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SizedBox(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: const Text("Camera"),
  //               onTap: () {
  //                 // Handle camera button tap
  //                 getImage(true, index,
  //                         source: ImageSource.camera, context: context)
  //                     .then((value) {
  //                   if (value != null) {
  //                     imagelist.add(value);
  //                     setState(() {});
  //                   }
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: const Text("Gallery"),
  //               onTap: () {
  //                 // Handle gallery button tap
  //                 getImage(true, index,
  //                         source: ImageSource.gallery, context: context)
  //                     .then((value) {
  //                   setState(() {
  //                     imagelist.add(value!);
  //                   });
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // _getUploadVideo() => Column(
  //       children: [
  //         GestureDetector(
  //           behavior: HitTestBehavior.translucent,
  //           onTap: () {
  //             _showBottomVideo();
  //           },
  //           child: Container(
  //             // height: 100,
  //             width: screenSize!.width,
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(26),
  //                 border: Border.all(color: AppColors.primary, width: 2)),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 IconButton(
  //                   onPressed: () {
  //                     _showBottomVideo();
  //                   },
  //                   icon: Image.asset(
  //                     AppIcons.icUpload,
  //                     height: 44.44,
  //                     width: 44.44,
  //                     fit: BoxFit.cover,
  //                   ),
  //                 ),
  //                 getTextWidget(
  //                   title: 'Select Video',
  //                   textFontSize: AppFonts.size18,
  //                   textColor: AppColors.primary,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         _videos.isEmpty
  //             ? Container()
  //             : Padding(
  //                 padding:
  //                     const EdgeInsets.only(top: 16.0, right: 8.0, left: 0.0),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: SizedBox(
  //                         height: 104,
  //                         width: 224,
  //                         child: ListView.builder(
  //                           itemCount: _videos.length,
  //                           shrinkWrap: true,
  //                           scrollDirection: Axis.horizontal,
  //                           itemBuilder: (BuildContext context, int index) {
  //                             return Padding(
  //                               padding: const EdgeInsets.only(right: 8.0),
  //                               child: Stack(
  //                                 children: [
  //                                   _videos[index].localFile != null
  //                                       ? FutureBuilder<Uint8List?>(
  //                                           future: generateLocalThumbnail(
  //                                               _videos[index]
  //                                                       .localFile!
  //                                                       .path
  //                                                       .toString()
  //                                                       .isEmpty
  //                                                   ? _videos[index]
  //                                                       .localFile!
  //                                                       .path
  //                                                       .toString()
  //                                                   : _videos[index]
  //                                                       .localFile!
  //                                                       .path
  //                                                       .toString()),
  //                                           builder: (context, snapshot) {
  //                                             if (snapshot.connectionState ==
  //                                                     ConnectionState.done &&
  //                                                 snapshot.hasData) {
  //                                               return Stack(
  //                                                 children: [
  //                                                   ClipRRect(
  //                                                     borderRadius:
  //                                                         BorderRadius.circular(
  //                                                             8.95),
  //                                                     child: Stack(children: [
  //                                                       Image.memory(
  //                                                         snapshot.data!,
  //                                                         height: 104,
  //                                                         width: 224,
  //                                                         fit: BoxFit.cover,
  //                                                       ),
  //                                                       SizedBox(
  //                                                           height: 104,
  //                                                           width: 224,
  //                                                           child: VideoPlayer(
  //                                                             VideoPlayerController
  //                                                                 .networkUrl(
  //                                                               Uri.parse(_videos[
  //                                                                       index]
  //                                                                   .localFile!
  //                                                                   .toString()),
  //                                                             ),
  //                                                           )),
  //                                                     ]),
  //                                                   ),
  //                                                 ],
  //                                               );
  //                                             } else {
  //                                               // log(' The data is loading....  ${snapshot.data}');

  //                                               return Shimmer.fromColors(
  //                                                 enabled: true,
  //                                                 baseColor: Colors.grey
  //                                                     .withOpacity(0.3),
  //                                                 highlightColor: Colors.grey
  //                                                     .withOpacity(0.1),
  //                                                 child: ClipRRect(
  //                                                   borderRadius:
  //                                                       const BorderRadius.only(
  //                                                     topLeft:
  //                                                         Radius.circular(10),
  //                                                     topRight:
  //                                                         Radius.circular(10),
  //                                                     bottomLeft:
  //                                                         Radius.circular(10),
  //                                                     bottomRight:
  //                                                         Radius.circular(10),
  //                                                   ),
  //                                                   child: Container(
  //                                                     height: 104,
  //                                                     width: 224,
  //                                                     color: Colors.white,
  //                                                   ),
  //                                                 ),
  //                                               );
  //                                             }
  //                                           },
  //                                         )
  //                                       : FutureBuilder<Uint8List?>(
  //                                           future: generateThumbnail(
  //                                               _videos[index]
  //                                                       .url
  //                                                       .toString()
  //                                                       .isEmpty
  //                                                   ? _videos[index]
  //                                                       .localFile!
  //                                                       .toString()
  //                                                   : _videos[index]
  //                                                       .url
  //                                                       .toString()),
  //                                           builder: (context, snapshot) {
  //                                             if (snapshot.connectionState ==
  //                                                     ConnectionState.done &&
  //                                                 snapshot.hasData) {
  //                                               // log(' The data is here  ${snapshot.data}');
  //                                               return Stack(
  //                                                 children: [
  //                                                   ClipRRect(
  //                                                     borderRadius:
  //                                                         BorderRadius.circular(
  //                                                             8.95),
  //                                                     child: Stack(children: [
  //                                                       Image.memory(
  //                                                         snapshot.data!,
  //                                                         height: 104,
  //                                                         width: 224,
  //                                                         fit: BoxFit.cover,
  //                                                       ),
  //                                                       SizedBox(
  //                                                           height: 104,
  //                                                           width: 224,
  //                                                           child: VideoPlayer(
  //                                                               VideoPlayerController.networkUrl(
  //                                                                   Uri.parse(_videos[
  //                                                                           index]
  //                                                                       .url!
  //                                                                       .toString())))),
  //                                                     ]),
  //                                                   ),
  //                                                 ],
  //                                               );
  //                                             } else {
  //                                               // log(' The data is loading....  ${snapshot.data}');

  //                                               return Shimmer.fromColors(
  //                                                 enabled: true,
  //                                                 baseColor: Colors.grey
  //                                                     .withOpacity(0.3),
  //                                                 highlightColor: Colors.grey
  //                                                     .withOpacity(0.1),
  //                                                 child: ClipRRect(
  //                                                   borderRadius:
  //                                                       const BorderRadius.only(
  //                                                     topLeft:
  //                                                         Radius.circular(10),
  //                                                     topRight:
  //                                                         Radius.circular(10),
  //                                                     bottomLeft:
  //                                                         Radius.circular(10),
  //                                                     bottomRight:
  //                                                         Radius.circular(10),
  //                                                   ),
  //                                                   child: Container(
  //                                                     height: 104,
  //                                                     width: 224,
  //                                                     color: Colors.white,
  //                                                   ),
  //                                                 ),
  //                                               );
  //                                             }
  //                                           },
  //                                         ),
  //                                   Positioned.fill(
  //                                     child: Align(
  //                                       alignment: Alignment.center,
  //                                       child: IconButton(
  //                                         onPressed: () {
  //                                           // log('Path :- ${_videos[index].localFile!.path}');
  //                                           // log('Path :- ${_videos[index].url}');

  //                                           _videos[index].localFile != null
  //                                               ? Navigator.push(
  //                                                   context,
  //                                                   MaterialPageRoute(
  //                                                       builder: (context) =>
  //                                                           NewVideoPlay(
  //                                                             type: 'local',
  //                                                             pathh: _videos[
  //                                                                     index]
  //                                                                 .localFile!
  //                                                                 .path
  //                                                                 .toString(),
  //                                                           )))
  //                                               : Navigator.push(
  //                                                   context,
  //                                                   MaterialPageRoute(
  //                                                       builder: (context) =>
  //                                                           NewVideoPlay(
  //                                                             type: 'url',
  //                                                             pathh: _videos[
  //                                                                     index]
  //                                                                 .url!
  //                                                                 .toString(),
  //                                                           )));
  //                                         },
  //                                         icon: Icon(
  //                                           Icons.play_arrow,
  //                                           color: AppColors.white,
  //                                           size: 30,
  //                                           // fit: BoxFit.cover,
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   ),
  //                                   Positioned(
  //                                     top: -10,
  //                                     right: -10,
  //                                     child: IconButton(
  //                                         onPressed: () {
  //                                           setState(() {
  //                                             if (_videos[index].localFile !=
  //                                                 null) {
  //                                               _videos.removeAt(index);

  //                                               // controllers[index].dispose();
  //                                             } else {
  //                                               // removedVideo
  //                                               //     .add(_videos[index].id!);
  //                                               _videos.removeAt(index);
  //                                               // controllers[index].dispose();
  //                                             }

  //                                             controllers.removeAt(index);
  //                                           });
  //                                         },
  //                                         icon: Icon(
  //                                           Icons.close,
  //                                           size: 20,
  //                                           color: AppColors.blackColor,
  //                                         )),
  //                                   ),
  //                                 ],
  //                               ),
  //                             );
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //       ],
  //     );

  // void _showBottomVideo() {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SizedBox(
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.camera_alt),
  //               title: Text("Video From Camera"),
  //               onTap: () {
  //                 // Handle gallery button tap
  //                 _getVideo(
  //                   ImageSource.camera,
  //                 );
  //                 Navigator.pop(context);
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.photo_library),
  //               title: Text("Video From Gallery"),
  //               onTap: () {
  //                 // Handle gallery button tap
  //                 _getVideo(
  //                   ImageSource.gallery,
  //                 );
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _getVideo(ImageSource source) async {
  //   try {
  //     final video = await picker.pickVideo(source: source);
  //     if (video == null) {
  //       return;
  //     }
  //     final videoTemp = File(video.path);
  //     debugPrint('Temp File :- $videoTemp');

  //     // Create a new VideoPlayerController for the selected video
  //     final VideoPlayerController newController =
  //         VideoPlayerController.file(videoTemp);

  //     // Add the new controller to the list of controllers
  //     await newController.initialize();

  //     setState(() {
  //       controllers.add(newController);
  //       // Add the selected video to the list of videos
  //       _videos.add(StoredVideo(localFile: videoTemp));
  //     });

  //     // Initialize the new controller

  //     // Play the video
  //     // newController.play();
  //   } catch (e) {
  //     debugPrint('Failed to open Gallery $e');
  //   }
  // }
  Widget _getMediaList() {
    if (mediaFiles.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        height: 104,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mediaFiles.length,
          itemBuilder: (context, index) {
            final media = mediaFiles[index];
            final isLocal = media.file != null;
            final isVideo = media.enumtype == MediaTypeEnum.video;

            final mediaWidget =
                isVideo
                    ? _buildVideoWidget(media, isLocal)
                    : _buildImageWidget(media, isLocal);

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: mediaWidget,
                  ),
                  Positioned(
                    top: -6,
                    right: -6,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          mediaFiles.removeAt(index);
                          if (media.file == null && media.path != null) {
                            removedMediaPaths.add(media.path!);
                          }
                          if (isVideo && index < controllers.length) {
                            controllers[index].dispose();
                            controllers.removeAt(index);
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageWidget(dynamic media, bool isLocal) {
    return isLocal
        ? Image.file(media.file!, width: 104, height: 104, fit: BoxFit.cover)
        : Image.network(
          "${AppEndpoints.imgUrl}${media.path!}",
          width: 104,
          height: 104,
          fit: BoxFit.cover,
        );
  }

  Widget _buildVideoWidget(dynamic media, bool isLocal) {
    final videoPath =
        isLocal ? media.file!.path : "${AppEndpoints.imgUrl}${media.path!}";

    return Stack(
      children: [
        FutureBuilder<Uint8List?>(
          future: generateLocalThumbnail(videoPath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
              );
            }
            return Container(
              width: 104,
              height: 104,
              color: Colors.grey.shade200,
            );
          },
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewVideoPlay(pathh: videoPath),
                  ),
                );
              },
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        mediaFiles.add(
          Media(null, File(pickedFile.path), MediaTypeEnum.image, null, null),
        );
        // Media(type: MediaTypeEnum.image, file: File(pickedFile.path)));
      });
    }
  }

  void _getVideo(ImageSource source) async {
    try {
      final pickedFile = await picker.pickVideo(source: source);
      if (pickedFile != null) {
        final videoFile = File(pickedFile.path);
        final controller = VideoPlayerController.file(videoFile);
        await controller.initialize();
        controllers.add(controller);

        setState(() {
          mediaFiles.add(
            Media(null, videoFile, MediaTypeEnum.video, null, null),
          );
        });
      }
    } catch (e) {
      log('Video selection failed: $e');
    }
  }
}
