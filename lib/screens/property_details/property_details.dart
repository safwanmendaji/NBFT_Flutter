import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/screens/add_property/property_form.dart';
import 'package:flutter_nobrokeragefortenants/screens/customer_details/customer_details.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/widgets/custom_header_logo.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';
import 'package:flutter_nobrokeragefortenants/widgets/header.dart';
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

  const MyPropertyDetails({
    super.key,
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
    required this.sizetype,
  });

  @override
  State<MyPropertyDetails> createState() => _MyPropertyDetailsState();
}

class _MyPropertyDetailsState extends State<MyPropertyDetails> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  int _currentIndex = 0;
  List<Map<String, dynamic>> specification = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

    _offsetAnimation = Tween<Offset>(begin: const Offset(0, 0), end: const Offset(0, -0.08)).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempVideoPath = '${tempDir.path}/temp_video.mp4';
        final file = File(tempVideoPath);
        await file.writeAsBytes(response.bodyBytes);

        final uint8list = await VideoThumbnail.thumbnailData(video: tempVideoPath, imageFormat: ImageFormat.PNG, maxHeight: 400, quality: 50);
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

  // ------------------------------------------------------------------ HELPERS

  Widget _defaultImage({double? height, double? width}) {
    return Container(height: height, width: width, color: const Color(0xFFEDF1F0), alignment: Alignment.center, child: const Icon(Icons.apartment_rounded, size: 64, color: AppColors.primary));
  }

  String get _formattedPrice {
    final parsed = int.tryParse(widget.price.toString()) ?? 0;
    return NumberFormat.decimalPattern('en_IN').format(parsed);
  }

  bool _isEmpty(String? value) => value == null || value.trim().isEmpty;

  // ------------------------------------------------------------------- BUILD

  @override
  Widget build(BuildContext context) {
    specification = [
      {'icon': AppIcons.icBothSideArrow, 'title': 'Size', 'isicon': false, 'subtitle': _isEmpty(widget.size) ? '-' : "${widget.size} ${widget.sizetype}"},
      {'icon': Icons.bed_outlined, 'title': 'BHK', 'isicon': true, 'subtitle': _isEmpty(widget.format) ? '-' : widget.format},
      {'icon': AppIcons.icCategory, 'title': 'Category', 'isicon': false, 'subtitle': _isEmpty(widget.category) ? '-' : widget.category},
      {'icon': Icons.area_chart_outlined, 'title': 'Area', 'isicon': true, 'subtitle': _isEmpty(widget.area) ? '-' : widget.area},
      {'icon': Icons.home_outlined, 'title': 'Floor', 'isicon': true, 'subtitle': _isEmpty(widget.floor) ? '-' : widget.floor},
      {'icon': Icons.chair_outlined, 'title': 'Furnished', 'isicon': true, 'subtitle': _isEmpty(widget.furnished) ? '-' : widget.furnished},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Column(
        children: [
          const MyCustomHeaderLogo(),
          const MyCustomHeader(title: "Property Details", isBackButton: true),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getImageList(),
                  const SizedBox(height: 16),
                  _titleAndPriceCard(),
                  const SizedBox(height: 16),
                  _addressCard(),
                  const SizedBox(height: 16),
                  _descriptionCard(),
                  const SizedBox(height: 20),
                  _getPropertySpecification(),
                  const SizedBox(height: 10),
                  _getButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- IMAGE LIST

  Widget _getImageList() {
    final hasImages = widget.images.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 260,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // --- Media ---
              hasImages
                  ? PageView.builder(
                    itemCount: widget.images.length,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (v) {
                      setState(() => _currentIndex = v);
                    },
                    itemBuilder: (context, index) {
                      return _buildMediaItem(widget.images[index]);
                    },
                  )
                  : _defaultImage(height: 260, width: double.infinity),

              // --- Soft gradient for legibility ---
              if (hasImages)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: 0.28), Colors.transparent, Colors.black.withValues(alpha: 0.35)],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

              // --- Counter badge ---
              if (hasImages)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
                    child: Text('${_currentIndex + 1} / ${widget.images.length}', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
                  ),
                ),

              // --- Type badge ---
              if (!_isEmpty(widget.type))
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10.5, letterSpacing: 0.5, fontWeight: FontWeight.w700)),
                  ),
                ),

              // --- Dots ---
              if (hasImages && widget.images.length > 1)
                Positioned(
                  bottom: 12,
                  child: DotsIndicator(
                    dotsCount: widget.images.length,
                    position: _currentIndex.toDouble(),
                    decorator: DotsDecorator(
                      activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.0)),
                      size: const Size(8.0, 8.0),
                      activeSize: const Size(22.0, 8.0),
                      color: Colors.white.withValues(alpha: 0.5),
                      activeColor: Colors.white,
                      spacing: const EdgeInsets.symmetric(horizontal: 5.0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaItem(Media media) {
    final path = media.path;
    if (_isEmpty(path)) {
      return _defaultImage(height: 260, width: double.infinity);
    }

    if (media.type == "image") {
      return CachedNetworkImage(
        imageUrl: "${AppEndpoints.imgUrl}$path",
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 260, color: Colors.grey)),
        errorWidget: (_, __, ___) => _defaultImage(height: 260, width: double.infinity),
      );
    }

    // Video
    return FutureBuilder<Uint8List?>(
      future: generateThumbnail("${AppEndpoints.imgUrl}$path"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              children: [
                Image.memory(snapshot.data!, height: 260, width: double.infinity, fit: BoxFit.cover),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NewVideoPlay(type: 'url', pathh: "${AppEndpoints.imgUrl}$path")));
                      },
                      child: Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 14)]),
                        child: const Icon(Icons.play_arrow_rounded, size: 38, color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return _defaultImage(height: 260, width: double.infinity);
        }
        return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: 260, color: Colors.grey));
      },
    );
  }

  // ------------------------------------------------------ TITLE + PRICE CARD

  Widget _titleAndPriceCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEmpty(widget.companyname) ? 'Untitled Property' : widget.companyname,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.blackColor, height: 1.3),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.currency_rupee_rounded, size: 15, color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Text('$_formattedPrice /-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                    ],
                  ),
                ),
                const Spacer(),
                if (!_isEmpty(widget.negotiable))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFE7F1EF), borderRadius: BorderRadius.circular(20)),
                    child: Text(widget.negotiable.toLowerCase() == 'yes' ? 'Negotiable' : 'Fixed Price', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ ADDRESS CARD

  Widget _addressCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(Icons.location_on_outlined, 'Address'),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(color: const Color(0xFFE7F1EF), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.place_outlined, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(_isEmpty(widget.address) ? '-' : widget.address, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.blackColor, height: 1.45)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------- DESCRIPTION CARD

  Widget _descriptionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel(Icons.description_outlined, 'Description'),
            const SizedBox(height: 10),
            Text(
              _isEmpty(widget.description) ? 'No description provided.' : widget.description,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.blackColor, height: 1.55),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String label) {
    return Row(
      children: [Icon(icon, size: 17, color: AppColors.primary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.primary))],
    );
  }

  // ----------------------------------------------------- SPECIFICATION GRID

  Widget _getPropertySpecification() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(Icons.grid_view_rounded, 'Property Specifications'),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: specification.length,
            itemBuilder: (BuildContext context, int index) {
              return _specCard(specification[index]);
            },
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisExtent: 140, mainAxisSpacing: 14, crossAxisSpacing: 14),
          ),
        ],
      ),
    );
  }

  Widget _specCard(Map<String, dynamic> spec) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0F1)),
        boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideTransition(
            position: _offsetAnimation,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(color: const Color(0xFFE7F1EF), borderRadius: BorderRadius.circular(12)),
              child: Center(
                child:
                    spec['isicon'] == true
                        ? Icon(spec['icon'] as IconData, size: 20, color: AppColors.primary)
                        : Image.asset(spec['icon'] as String, height: 20, width: 20, fit: BoxFit.contain, color: AppColors.primary),
              ),
            ),
          ),
          const Spacer(),
          Text(spec['title'] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.gray500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text('${spec['subtitle']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.blackColor, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- ACTION BTNS

  Widget _getButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        children: [
          _actionButton(
            icon: AppIcons.icEditOutline,
            label: 'Edit Property',
            filled: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => MyAddPropertyForm(
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
                        selectSizetype: widget.sizetype,
                        selectState: "Gujarat",
                      ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _actionButton(
            icon: AppIcons.icCustomerDetail,
            label: 'Customer Details',
            filled: false,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MyCustomerDetails(propertyId: widget.propertyid)));
            },
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required String icon, required String label, required VoidCallback onTap, required bool filled}) {
    final bg = filled ? AppColors.secondary : AppColors.white;
    final fg = filled ? AppColors.white : AppColors.secondary;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: filled ? 3 : 0,
          shadowColor: filled ? const Color(0x33DFA24A) : null,
          side: filled ? null : const BorderSide(color: Color(0xFFDFA24A), width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                color: filled ? AppColors.white : AppColors.secondary,
                errorBuilder: (_, __, ___) => Icon(filled ? Icons.edit_outlined : Icons.person_outline, size: 20, color: filled ? AppColors.white : AppColors.secondary),
              ),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: fg)),
          ],
        ),
      ),
    );
  }
}
