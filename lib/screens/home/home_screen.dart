import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
 import 'package:flutter_nobrokeragefortenants/screens/profile/profile_screen.dart';
 import 'package:flutter_nobrokeragefortenants/screens/property_details/property_details.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_option.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_bottom_tab.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
 import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
 import 'package:flutter_nobrokeragefortenants/core/utils/current_date.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
 import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';

class MyNewHomeScreen extends StatefulWidget {
  const MyNewHomeScreen({super.key});

  @override
  State<MyNewHomeScreen> createState() => _MyNewHomeScreenState();
}

class _MyNewHomeScreenState extends State<MyNewHomeScreen> {
  final _searchController = TextEditingController();

  List option = ["All", "Commercial", "Residential"];

  double priceRange = 10000.0;
  List floor = ["Ground floor", "First floor", "Second", "Third", "Any"];

  String selectedCategory = '';
  List category = ["Flat", "Bunglow", "Plant House", "Office", "Shop"];
  List format = ["1 BHK", "2 BHK", "3 BHK", "4 BHK"];

  List furnished = ["Fully", "Semi", "Unfurnished"];
  List propertiesCard = [];

  List<double> values = [5000, 50000];
  double _lowervalue = 5000.0;
  double _uppervalue = 15000.0;

  // int isSelect = 0;
  int? isSelected = 0;
  int? isFloorSelected;
  int? isCategoerySelected;
  int? isFormatSelected;
  int? isFurnished;
  // String? selectedSize;
  double _headerOpacity = 1.0;
  double _lastOffset = 0.0;

  int? totalProperties = 0;
  int? pendingProperties = 0;
  int? dealClosed = 0;
  List<Map<String, dynamic>> recentLeads = [];

  List<Data> homeproperty = [
    // MyHomeProperty(
    //   image: AppIcons.icProperty
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
    // MyHomeProperty(
    //   image: AppIcons.icProperty,
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
    // MyHomeProperty(
    //   image: AppIcons.icProperty,
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
    // MyHomeProperty(
    //   image: AppIcons.icProperty,
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
    // MyHomeProperty(
    //   image: AppIcons.icProperty,
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
    // MyHomeProperty(
    //   image: AppIcons.icProperty,
    //   name: "Swarnim Business Center",
    //   floor: "Ground floor",
    //   location: "South bopal, Ahmedabad",
    //   price: "25000",
    //   squarefeet: "750",
    // ),
  ];

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

  _dashboardApi() async {
    await Authapi.dashboardapi(
          context: context,
          id: Prefs.getString(LocalStrings.userid),
        )
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            log("APi Success");
            totalProperties = response.data!.totalProperties!;
            pendingProperties = response.data!.activeProperties!;
            dealClosed = response.data!.closedDeals!;
            setState(() {});
          } else {
            log("Api failed");
          }
        })
        .catchError((error) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  _interestApi() async {
    await Authapi.brokerLeads(context: context)
        .then((response) {
          final payload =
              response is Map<String, dynamic> ? response['data'] : response;
          final value =
              payload is Map<String, dynamic>
                  ? payload['recentLeads']
                  : payload;
          if (value is List) {
            recentLeads =
                value
                    .whereType<Map>()
                    .map((lead) => Map<String, dynamic>.from(lead))
                    .toList();
            if (mounted) setState(() {});
          }
        })
        .catchError((_) {});
  }

  // _propertiesApi() async {
  //   await Propertyapis.getproperties(
  //       isShowProgress: false,
  //       context: context,
  //       id: Prefs.getString(LocalStrings.userid),
  //       params: {}).then((response) {
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       log("APi Success");
  //       homeproperty = response.data ?? [];
  //       setState(() {});
  //     } else {
  //       log("Api failed");
  //     }
  //   }).catchError((error) {
  //     ErrorManager().showErrorDialogue(e: error, context: context);
  //     homeproperty = [];

  //     setState(() {});
  //   }).onError((error, stacktrace) {
  //     ErrorManager().showErrorDialogue(e: error, context: context);
  //   });
  // }

  _propertiesApi({int? from}) async {
    // var filterparams = {

    // };

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
                  ? {"type": isSelected != 0 ? option[isSelected!] : ""}
                  : {
                    "search": _searchController.text.toString(),
                    "category":
                        isCategoerySelected != null
                            ? category[isCategoerySelected!]
                            : "",
                    "type": isSelected != null ? option[isSelected!] : "",
                    "format":
                        isFormatSelected != null
                            ? format[isFormatSelected!]
                            : "",
                    "furnished":
                        isFurnished != null ? furnished[isFurnished!] : "",
                    "priceRange":
                        priceRange != null ? priceRange.toString() : "",
                    "floor":
                        isFloorSelected != null ? floor[isFloorSelected!] : "",
                  },
        )
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            // isSelected = 0;
            // isFloorSelected = 0;
            // isCategoerySelected = 0;
            // isFormatSelected = 0;
            // isFurnished = 0;

            // selectedSize = '';

            log("APi Success");
            homeproperty = response.data ?? [];

            setState(() {});
          } else {
            log("Api failed");
          }
        })
        .catchError((error) {
          homeproperty = [];

          setState(() {});
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(Durations.medium1, () {
      _propertiesApi(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Poppins'),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${Prefs.getString(LocalStrings.username)} 👋',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (_showPlanBanner) ...[
                        const SizedBox(height: 14),
                        _planBanner(),
                      ],
                      const SizedBox(height: 18),
                      _sectionTitle(
                        'My Properties',
                        '${homeproperty.length} listed',
                      ),
                      const SizedBox(height: 6),
                      _getProperties(),
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

  int? get _planDaysLeft {
    final expiry = DateTime.tryParse(
      Prefs.getString(LocalStrings.userplanexpiry),
    );
    if (expiry == null) return null;
    return expiry.difference(DateTime.now()).inDays;
  }

  bool get _showPlanBanner {
    final days = _planDaysLeft;
    return days != null && days <= 30;
  }

  Widget _planBanner() {
    final days = _planDaysLeft ?? 0;
    final savedName = Prefs.getString(LocalStrings.userplanname);
    final planName = savedName.isEmpty ? 'Current Plan' : savedName;
    final expired = days < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF163E3A)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFFE6C77A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  expired
                      ? 'Your plan has expired'
                      : 'Expires in $days ${days == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    color: Color(0xFFEAE7E1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Renew',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning!';
    if (hour < 17) return 'Good afternoon!';
    return 'Good evening!';
  }

  Widget _summaryCard(IconData icon, String label, int value, Color tint) {
    return Container(
      width: 112,
      height: 122,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xffedf0f1)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            backgroundColor: tint,
            radius: 16,
            child: Icon(icon, color: AppColors.primary, size: 19),
          ),
          Text(
            '$value',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(color: AppColors.gray500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String action) => Row(
    children: [
      Expanded(
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      Text(
        action,
        style: const TextStyle(color: AppColors.secondary, fontSize: 11),
      ),
    ],
  );

  Widget _panel({required Widget child, double height = 116}) => SizedBox(
    height: height,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xffedf0f1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    ),
  );

  Widget _heroProperty() {
    return SizedBox(
      height: 116,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(color: const Color(0xfff4f0e8)),
            Positioned.fill(
              child: Image.asset(
                'assets/images/hero_bungalow.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (context, error, stackTrace) {
                  final property =
                      homeproperty.isEmpty ? null : homeproperty.first;
                  final path =
                      property?.media?.isNotEmpty == true
                          ? property!.media!.first.path
                          : null;
                  if (path == null)
                    return Image.asset(AppIcons.icProperty, fit: BoxFit.cover);
                  return CachedNetworkImage(
                    imageUrl: '${AppEndpoints.imgUrl}$path',
                    fit: BoxFit.cover,
                    errorWidget:
                        (_, __, ___) =>
                            Image.asset(AppIcons.icProperty, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadContent(Map<String, dynamic> lead, String label) {
    final customer =
        lead['customer'] is Map
            ? Map<String, dynamic>.from(lead['customer'])
            : lead;
    final property =
        lead['property'] is Map
            ? Map<String, dynamic>.from(lead['property'])
            : lead;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: Color(0xffe7f1ef),
            child: Icon(
              Icons.person_outline,
              size: 17,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _leadValue(customer, ['fullName', 'name'], 'Customer'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _leadValue(property, [
                    'title',
                    'propertyName',
                  ], 'Property interest'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (label.isNotEmpty)
            Text(
              label,
              style: const TextStyle(color: AppColors.secondary, fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget _propertyCard(Data property) {
    final path =
        property.media?.isNotEmpty == true ? property.media!.first.path : null;
    return Container(
      width: 145,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0xffedf0f1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child:
                path == null
                    ? Image.asset(
                      AppIcons.icProperty,
                      height: 92,
                      width: 129,
                      fit: BoxFit.cover,
                    )
                    : CachedNetworkImage(
                      imageUrl: '${AppEndpoints.imgUrl}$path',
                      height: 92,
                      width: 129,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(height: 6),
          Text(
            property.title ?? 'Untitled property',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(
            property.location ?? property.area ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.gray500, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _leadRow(String name, String detail, String time, Color tint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tint,
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AppColors.gray500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(color: AppColors.gray500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _leadValue(
    Map<String, dynamic> lead,
    List<String> keys,
    String fallback,
  ) {
    for (final key in keys) {
      final value = lead[key];
      if (value != null && value.toString().isNotEmpty) return value.toString();
    }
    return fallback;
  }

  _getProperties() =>
      homeproperty.isEmpty
          ? Lottie.asset(
            "assets/animation/no_properties.json",
            height: 60,
            width: screenSize!.width,
            fit: BoxFit.cover,
          )
          : ListView.builder(
            itemCount: homeproperty.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child:
                          homeproperty[index].media!.first.type == "image"
                              ? CachedNetworkImage(
                                placeholder:
                                    (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 200,
                                        width: screenSize!.width,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                imageUrl:
                                    "${AppEndpoints.imgUrl}${homeproperty[index].media!.first.path!}",
                                height: 200,
                                width: screenSize!.width,
                                fit: BoxFit.cover,
                              )
                              : FutureBuilder<Uint8List?>(
                                future: generateThumbnail(
                                  "${AppEndpoints.imgUrl}${homeproperty[index].media!.first.path!}",
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Stack(
                                      children: [
                                        Image.memory(
                                          snapshot.data!,
                                          height: 200,
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
                                        height: 200,
                                        width: screenSize!.width,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                },
                              ),
                    ),
                    // ClipRRect(
                    //   borderRadius: const BorderRadius.only(
                    //     topLeft: Radius.circular(12),
                    //     topRight: Radius.circular(12),
                    //   ),
                    //   child: Image.asset(
                    //     AppIcons.icProperty,
                    // height: 200,
                    // width: screenSize!.width,
                    //     fit: BoxFit.cover,
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              spreadRadius: 5,
                              blurStyle: BlurStyle.outer,
                              offset: Offset(0, 0),
                              color: AppColors.daycolor,
                            ),
                          ],
                        ),
                        // border: Border(
                        //     bottom: BorderSide(
                        //       width: 1,
                        //       color: AppColors.darkgreycolor,
                        //     ),
                        //     left: BorderSide(
                        //       width: 1,
                        //       color: AppColors.darkgreycolor,
                        //     ),
                        //     right: BorderSide(
                        //       width: 1,
                        //       color: AppColors.darkgreycolor,
                        //     ))),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            top: 10,
                            bottom: 8.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: screenSize!.width,
                                child: getTextWidget(
                                  title: homeproperty[index].title!,
                                  textFontSize: AppFonts.size18,
                                  maxLines: 1,
                                  textFontWeight: AppFonts.bold,
                                  textColor: AppColors.blackColor,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Image.asset(
                                    AppIcons.icRuppee,
                                    height: 15,
                                    width: 15,
                                    color: AppColors.secondary,
                                    fit: BoxFit.cover,
                                  ),
                                  getTextWidget(
                                    title:
                                        homeproperty[index].price!.toString(),
                                    textFontSize: AppFonts.size17,
                                    textFontWeight: AppFonts.semiBold,
                                    textColor: AppColors.secondary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Row(
                                children: [
                                  Image.asset(
                                    AppIcons.icLocation,
                                    height: 12,
                                    width: 12,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(width: 5.0),
                                  SizedBox(
                                    width: screenSize!.width - 90,
                                    child: getTextWidget(
                                      title: homeproperty[index].location!,
                                      textFontSize: AppFonts.size15,
                                      textFontWeight: AppFonts.medium,
                                      maxLines: 1,
                                      textColor: AppColors.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset(
                                      AppIcons.icBothSideArrow,
                                      height: 20,
                                      width: 20,
                                      fit: BoxFit.cover,
                                      color: AppColors.primary,
                                    ),
                                    getTextWidget(
                                      title:
                                          '${homeproperty[index].size} sqft  ,',
                                      textFontSize: AppFonts.size13,
                                      textFontWeight: AppFonts.medium,
                                      textColor: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8.0),
                                    const Icon(
                                      Icons.bed,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 3.0),
                                    getTextWidget(
                                      title: '${homeproperty[index].format}',
                                      textFontSize: AppFonts.size13,
                                      textFontWeight: AppFonts.medium,
                                      textColor: AppColors.primary,
                                    ),
                                    const Spacer(),
                                    getTextWidget(
                                      title: homeproperty[index].type!,
                                      textFontSize: AppFonts.size13,
                                      textFontWeight: AppFonts.bold,
                                      textColor: AppColors.blackColor,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => MyPropertyDetails(
                                            sizetype:
                                                homeproperty[index].sizeType!,
                                            type: homeproperty[index].type!,
                                            size: homeproperty[index].size!,
                                            images: homeproperty[index].media!,
                                            squarefeet:
                                                homeproperty[index].sizeType!,
                                            companyname:
                                                homeproperty[index].title!,
                                            price:
                                                homeproperty[index].price!
                                                    .toString(),
                                            address:
                                                homeproperty[index].location!,
                                            description:
                                                homeproperty[index]
                                                    .description!,
                                            format: homeproperty[index].format!,
                                            category:
                                                homeproperty[index].category!,
                                            furnished:
                                                homeproperty[index].furnished!,
                                            area: homeproperty[index].area!,
                                            negotiable: "No",
                                            propertyid:
                                                homeproperty[index].sId!,
                                            floor: homeproperty[index].floor!,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 35,
                                  width: screenSize!.width,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppColors.primary,
                                  ),
                                  child: Center(
                                    child: getTextWidget(
                                      title: "View Details",
                                      textFontSize: AppFonts.size12,
                                      textColor: AppColors.white,
                                      textFontWeight: AppFonts.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

  _getOptions() => Padding(
    padding: const EdgeInsets.only(top: 11.0),
    child: Container(
      width: screenSize!.width,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: const Color(0XFFDFE0E2), width: 1.0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          top: 6.39,
          bottom: 6.39,
          right: 1.0,
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
                  _propertiesApi(from: 3);
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

  _getCurrentDay() => SizedBox(
    child: getTextWidget(
      textAlign: TextAlign.end,
      title: getFormattedDate(),
      textFontSize: AppFonts.size13,
      textFontWeight: AppFonts.semiBold,
      textColor: AppColors.white,
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
          _propertiesApi(from: 2);
        });
      },
      // borderColor: AppColors.white,
      // onChange: (value) {
      //   _propertiesApi(from: 2);
      //   setState(() {});
      // },
      prefixIcon: AppIcons.icSearch,
      prefixiconcolor: const Color(0XFFA1A9B8),
    ),
  );

  _getFilter() => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: () {
      getBottomSheet();
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

  getBottomSheet() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (builder) {
      // Reset selections initially
      isSelected = null;
      isFloorSelected = null;
      isCategoerySelected = null;
      isFormatSelected = null;
      isFurnished = null;

      return StatefulBuilder(
        builder: (context, mystate) {
          String? categoryName =
              isCategoerySelected != null
                  ? category[isCategoerySelected!]
                  : null;

          return Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(38),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 44.0,
                right: 20.0,
                bottom: 12.0,
              ),
              child: SingleChildScrollView(
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
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              right: 8.0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                mystate(() {
                                  isSelected = null;
                                  isFloorSelected = null;
                                  isCategoerySelected = null;
                                  isFormatSelected = null;
                                  isFurnished = null;
                                  _lowervalue = 5000;
                                  _uppervalue = 15000;
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
                    const SizedBox(height: 16),

                    /// Category
                    getTextWidget(
                      title: 'Category',
                      textFontSize: AppFonts.size15,
                      textFontWeight: AppFonts.bold,
                      textColor: AppColors.blackColor,
                    ),
                    const SizedBox(height: 8.0),
                    OptionSelector(
                      options: category,
                      selectedIndex: isCategoerySelected,
                      onTap: (index) {
                        mystate(() {
                          isCategoerySelected = index;
                        });
                      },
                    ),

                    /// Floor (hide if "Bunglow")
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child:
                          categoryName == 'Bunglow'
                              ? const SizedBox()
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 21),
                                  getTextWidget(
                                    title: 'Floor',
                                    textFontSize: AppFonts.size15,
                                    textFontWeight: AppFonts.bold,
                                    textColor: AppColors.blackColor,
                                  ),
                                  const SizedBox(height: 8.0),
                                  OptionSelector(
                                    options: floor,
                                    selectedIndex: isFloorSelected,
                                    onTap: (index) {
                                      mystate(() {
                                        isFloorSelected = index;
                                      });
                                    },
                                  ),
                                ],
                              ),
                    ),

                    const SizedBox(height: 21),

                    /// Price Range
                    getTextWidget(
                      title: 'Price Range',
                      textFontSize: AppFonts.size15,
                      textFontWeight: AppFonts.bold,
                      textColor: AppColors.blackColor,
                    ),
                    FlutterSlider(
                      values: [_lowervalue, _uppervalue],
                      rangeSlider: true,
                      ignoreSteps: [
                        FlutterSliderIgnoreSteps(from: 8000, to: 12000),
                        FlutterSliderIgnoreSteps(from: 18000, to: 22000),
                      ],
                      max: 150000,
                      min: 1000,
                      step: const FlutterSliderStep(step: 1000),
                      jump: true,
                      trackBar: FlutterSliderTrackBar(
                        activeTrackBarHeight: 8,
                        inactiveTrackBarHeight: 8,
                        inactiveTrackBar: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.greyColor,
                        ),
                        activeTrackBar: BoxDecoration(color: AppColors.primary),
                      ),
                      tooltip: FlutterSliderTooltip(alwaysShowTooltip: false),
                      handler: FlutterSliderHandler(
                        decoration: const BoxDecoration(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      rightHandler: FlutterSliderHandler(
                        decoration: const BoxDecoration(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),
                      onDragging: (handlerIndex, lowerValue, upperValue) {
                        _lowervalue = lowerValue;
                        _uppervalue = upperValue;
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 21),

                    /// Format (hide if "Office")
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child:
                          categoryName == 'Office'
                              ? const SizedBox()
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  getTextWidget(
                                    title: 'Format',
                                    textFontSize: AppFonts.size15,
                                    textFontWeight: AppFonts.bold,
                                    textColor: AppColors.blackColor,
                                  ),
                                  const SizedBox(height: 8.0),
                                  OptionSelector(
                                    options: format,
                                    selectedIndex: isFormatSelected,
                                    onTap: (index) {
                                      mystate(() {
                                        isFormatSelected = index;
                                      });
                                    },
                                  ),
                                ],
                              ),
                    ),

                    const SizedBox(height: 21.0),

                    /// Furnished
                    getTextWidget(
                      title: 'Furnished',
                      textFontSize: AppFonts.size15,
                      textFontWeight: AppFonts.bold,
                      textColor: AppColors.blackColor,
                    ),
                    const SizedBox(height: 8.0),
                    OptionSelector(
                      options: furnished,
                      selectedIndex: isFurnished,
                      onTap: (index) {
                        mystate(() {
                          isFurnished = index;
                        });
                      },
                    ),
                    const SizedBox(height: 21.0),

                    CustomizedButton(
                      buttonColor: AppColors.primary,
                      title: 'Filter Properties',
                      textColor: AppColors.white,
                      onTap: () {
                        mystate(() {
                          Navigator.pop(context);
                          _propertiesApi(from: 1);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _SliverHeaderLogoDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverHeaderLogoDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderLogoDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _SliverSearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverSearchBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverSearchBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
