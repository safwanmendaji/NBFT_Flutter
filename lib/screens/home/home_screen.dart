import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/screens/add_property/add_properties_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/property_details/property_details.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyNewHomeScreen extends StatefulWidget {
  const MyNewHomeScreen({super.key});

  @override
  State<MyNewHomeScreen> createState() => _MyNewHomeScreenState();
}

class _MyNewHomeScreenState extends State<MyNewHomeScreen> {
  final _searchController = TextEditingController();

  // ---------------- Filter option lists ----------------
  final List<String> option = ["All", "Commercial", "Residential"];
  final List<String> floor = ["Ground floor", "First floor", "Second", "Third", "Any"];
  final List<String> category = ["Flat", "Bunglow", "Plant House", "Office", "Shop"];
  final List<String> format = ["1 BHK", "2 BHK", "3 BHK", "4 BHK"];
  final List<String> furnished = ["Fully", "Semi", "Unfurnished"];

  // ---------------- Selected filter indices ----------------
  int? isSelected = 0;
  int? isFloorSelected;
  int? isCategoerySelected;
  int? isFormatSelected;
  int? isFurnished;

  // ---------------- Price range (defaults = full range) -----
  static const double _minPrice = 1000;
  static const double _maxPrice = 150000;
  double _lowervalue = _minPrice;
  double _uppervalue = _maxPrice;

  // ---------------- Data ----------------
  List<Data> _allProperties = [];
  List<Data> homeproperty = [];

  int? totalProperties = 0;
  int? pendingProperties = 0;
  int? dealClosed = 0;
  List<Map<String, dynamic>> recentLeads = [];

  bool _isLoading = true;

  // ---------------------------------------------------------------- LIFECYCLE

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      _propertiesApi();
      _dashboardApi();
      _interestApi();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- API CALLS

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final tempVideoPath = '${tempDir.path}/temp_video.mp4';
        final file = File(tempVideoPath);
        await file.writeAsBytes(response.bodyBytes);

        return await VideoThumbnail.thumbnailData(video: tempVideoPath, imageFormat: ImageFormat.PNG, maxHeight: 400, quality: 50);
      }
      log('Failed to download video');
      return null;
    } catch (e) {
      log('Error generating thumbnail: $e');
      return null;
    }
  }

  _dashboardApi() async {
    await Authapi.dashboardapi(context: context, id: Prefs.getString(LocalStrings.userid))
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            totalProperties = response.data!.totalProperties!;
            pendingProperties = response.data!.activeProperties!;
            dealClosed = response.data!.closedDeals!;
            if (mounted) setState(() {});
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
          final payload = response is Map<String, dynamic> ? response['data'] : response;
          final value = payload is Map<String, dynamic> ? payload['recentLeads'] : payload;
          if (value is List) {
            recentLeads = value.whereType<Map>().map((lead) => Map<String, dynamic>.from(lead)).toList();
            if (mounted) setState(() {});
          }
        })
        .catchError((_) {});
  }

  _propertiesApi() async {
    if (mounted) setState(() => _isLoading = true);

    await Propertyapis.getproperties(isShowProgress: false, context: context, id: Prefs.getString(LocalStrings.userid), params: const {})
        .then((response) {
          if (response.statusCode == 201 || response.statusCode == 200) {
            log("APi Success");
            _allProperties = response.data ?? [];
            _applyFilters();
            if (mounted) setState(() => _isLoading = false);
          } else {
            if (mounted) setState(() => _isLoading = false);
          }
        })
        .catchError((error) {
          _allProperties = [];
          homeproperty = [];
          if (mounted) setState(() => _isLoading = false);
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          if (mounted) setState(() => _isLoading = false);
          ErrorManager().showErrorDialogue(e: error, context: context);
        });
  }

  // --------------------------------------------------------------- LOCAL FILTER

  void _applyFilters() {
    final search = _searchController.text.trim().toLowerCase();

    final filtered =
        _allProperties.where((p) {
          // Search
          if (search.isNotEmpty) {
            final hay = [p.title ?? '', p.location ?? '', p.area ?? '', p.description ?? '', p.category ?? '', p.type ?? '', p.format ?? ''].join(' ').toLowerCase();

            if (!hay.contains(search)) return false;
          }

          // Type
          if (isSelected != null && isSelected! > 0) {
            final wanted = option[isSelected!].toLowerCase();
            if ((p.type ?? '').toLowerCase() != wanted) return false;
          }

          // Category
          if (isCategoerySelected != null) {
            final wanted = category[isCategoerySelected!].toLowerCase();
            if ((p.category ?? '').toLowerCase() != wanted) return false;
          }

          // Floor
          if (isFloorSelected != null) {
            final wanted = floor[isFloorSelected!].toLowerCase();
            if (wanted != 'any' && (p.floor ?? '').toLowerCase() != wanted) {
              return false;
            }
          }

          // Format
          if (isFormatSelected != null) {
            final wanted = format[isFormatSelected!].toLowerCase();
            if ((p.format ?? '').toLowerCase() != wanted) return false;
          }

          // Furnished
          if (isFurnished != null) {
            final wanted = furnished[isFurnished!].toLowerCase();
            if ((p.furnished ?? '').toLowerCase() != wanted) return false;
          }

          // Price
          if (_lowervalue > _minPrice || _uppervalue < _maxPrice) {
            final price = int.tryParse(p.price?.toString() ?? '') ?? 0;
            if (price > 0 && (price < _lowervalue || price > _uppervalue)) {
              return false;
            }
          }

          return true;
        }).toList();

    if (mounted) {
      setState(() => homeproperty = filtered);
    } else {
      homeproperty = filtered;
    }
  }

  int get _activeFilterCount {
    int count = 0;
    if (isCategoerySelected != null) count++;
    if (isFloorSelected != null) count++;
    if (isFormatSelected != null) count++;
    if (isFurnished != null) count++;
    if (_lowervalue > _minPrice || _uppervalue < _maxPrice) count++;
    return count;
  }

  void _resetAdvancedFilters() {
    isCategoerySelected = null;
    isFloorSelected = null;
    isFormatSelected = null;
    isFurnished = null;
    _lowervalue = _minPrice;
    _uppervalue = _maxPrice;
  }

  // ------------------------------------------------------------------- HELPERS

  Widget _defaultPropertyImage({double? height, double? width, BoxFit fit = BoxFit.cover}) {
    return Image.asset(
      AppIcons.icProperty,
      height: height,
      width: width,
      fit: fit,
      errorBuilder:
          (_, __, ___) =>
              Container(height: height, width: width, color: const Color(0xFFEDF1F0), alignment: Alignment.center, child: const Icon(Icons.apartment_rounded, size: 46, color: AppColors.primary)),
    );
  }

  Widget _buildPropertyMedia(Data property, {required double height, double? width, BoxFit fit = BoxFit.cover}) {
    final media = property.media;

    if (media == null || media.isEmpty) {
      return _defaultPropertyImage(height: height, width: width, fit: fit);
    }

    final first = media.first;
    final String? path = first.path;

    if (path == null || path.trim().isEmpty) {
      return _defaultPropertyImage(height: height, width: width, fit: fit);
    }

    if (first.type == "image") {
      return CachedNetworkImage(
        imageUrl: "${AppEndpoints.imgUrl}$path",
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: height, width: width, color: Colors.grey)),
        errorWidget: (_, __, ___) => _defaultPropertyImage(height: height, width: width, fit: fit),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: generateThumbnail("${AppEndpoints.imgUrl}$path"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data != null) {
            return Stack(
              children: [
                Image.memory(snapshot.data!, height: height, width: width, fit: fit),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.35), shape: BoxShape.circle),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          }
          return _defaultPropertyImage(height: height, width: width, fit: fit);
        }
        return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(height: height, width: width, color: Colors.grey));
      },
    );
  }

  void _onAddProperty() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAddPropertiesScreen()));
  }

  // ------------------------------------------------------------------ UI PARTS

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddProperty,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Property', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await _propertiesApi();
            await _dashboardApi();
            await _interestApi();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontFamily: 'Poppins'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  if (_showPlanBanner) ...[const SizedBox(height: 16), _planBanner()],
                  const SizedBox(height: 18),
                  _searchAndFilterRow(),
                  const SizedBox(height: 12),
                  _typeChipsRow(),
                  const SizedBox(height: 18),
                  _statsRow(),
                  const SizedBox(height: 22),
                  _sectionHeader('My Properties', '${homeproperty.length} listed'),
                  const SizedBox(height: 12),
                  _getProperties(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- HEADER

  Widget _header() {
    final userName = Prefs.getString(LocalStrings.username);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(), style: const TextStyle(color: AppColors.gray500, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 3),
              Text(
                userName.isEmpty ? 'Welcome 👋' : '$userName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ],
          ),
        ),
        _circleIconButton(icon: Icons.add_home_work_outlined, onTap: _onAddProperty, filled: true),
        const SizedBox(width: 10),
        _circleIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }

  Widget _circleIconButton({required IconData icon, required VoidCallback onTap, bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: filled ? AppColors.primary : const Color(0xFFE6EAEA)),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8)],
        ),
        child: Icon(icon, size: 20, color: filled ? AppColors.white : AppColors.primary),
      ),
    );
  }

  // ------------------------------------------------------------ PLAN BANNER

  int? get _planDaysLeft {
    final expiry = DateTime.tryParse(Prefs.getString(LocalStrings.userplanexpiry));
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF163E3A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x1A1F4F4A), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(color: AppColors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.workspace_premium_outlined, color: Color(0xFFE6C77A), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(planName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 3),
                Text(expired ? 'Your plan has expired' : 'Expires in $days ${days == 1 ? 'day' : 'days'}', style: const TextStyle(color: Color(0xFFD7DCDA), fontSize: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Renew', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------- SEARCH + FILTER

  Widget _searchAndFilterRow() {
    return Row(children: [Expanded(child: _getSearchbar()), const SizedBox(width: 10), _getFilter()]);
  }

  Widget _getSearchbar() => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EAEA)),
      boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10)],
    ),
    child: PrimaryTextFeild(
      textInputAction: TextInputAction.search,
      hintText: 'Search property...',
      hintColor: const Color(0xFFA1A9B8),
      controller: _searchController,
      onChange: (value) => _applyFilters(),
      onfeildSubmitted: (value) => _applyFilters(),
      prefixIcon: AppIcons.icSearch,
      prefixiconcolor: const Color(0xFFA1A9B8),
    ),
  );

  Widget _getFilter() => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: getBottomSheet,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(14), boxShadow: const [BoxShadow(color: Color(0x1FDFA24A), blurRadius: 10, offset: Offset(0, 4))]),
          child: Row(
            children: [
              Image.asset(AppIcons.icFilter, height: 18, width: 18, fit: BoxFit.cover),
              const SizedBox(width: 8),
              getTextWidget(title: 'Filter', textFontSize: AppFonts.size14, textFontWeight: AppFonts.bold, textColor: AppColors.white),
            ],
          ),
        ),
        if (_activeFilterCount > 0)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              alignment: Alignment.center,
              child: Text('$_activeFilterCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
            ),
          ),
      ],
    ),
  );

  // -------------------------------------------------------- TYPE CHIPS ROW

  Widget _typeChipsRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        itemCount: option.length,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final selected = isSelected == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _typeChip(
              label: option[index],
              selected: selected,
              onTap: () {
                setState(() => isSelected = index);
                _applyFilters();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _typeChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE6EAEA)),
          boxShadow: selected ? const [BoxShadow(color: Color(0x1A1F4F4A), blurRadius: 8, offset: Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[const Icon(Icons.check_circle, size: 14, color: AppColors.white), const SizedBox(width: 6)],
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w600, color: selected ? AppColors.white : AppColors.gray500)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- STATS

  Widget _statsRow() {
    return SizedBox(
      height: 108,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _summaryCard(Icons.apartment_rounded, 'Total Properties', totalProperties ?? 0, const Color(0xFFE7F1EF)),
          _summaryCard(Icons.hourglass_bottom_rounded, 'Active Listings', pendingProperties ?? 0, const Color(0xFFFFF3E0)),
          _summaryCard(Icons.handshake_rounded, 'Deals Closed', dealClosed ?? 0, const Color(0xFFEDE7F6)),
          _summaryCard(Icons.people_alt_rounded, 'Recent Leads', recentLeads.length, const Color(0xFFE3F2FD)),
        ],
      ),
    );
  }

  Widget _summaryCard(IconData icon, String label, int value, Color tint) {
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0F1)),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(height: 32, width: 32, decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 17)),
          Text('$value', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.gray500, fontSize: 11)),
        ],
      ),
    );
  }

  // -------------------------------------------------------- SECTION HEADER

  Widget _sectionHeader(String title, String trailing) {
    return Row(
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFFE7F1EF), borderRadius: BorderRadius.circular(20)),
          child: Text(trailing, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _onAddProperty,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.add, size: 18, color: AppColors.white),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- GREETING

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ----------------------------------------------------------- PROPERTY LIST

  Widget _getProperties() {
    if (_isLoading) {
      return Column(children: List.generate(3, (index) => _shimmerCard()));
    }

    if (homeproperty.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      itemCount: homeproperty.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return _propertyCard(homeproperty[index]);
      },
    );
  }

  Widget _shimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Container(height: 180, decoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)))),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 180, color: Colors.grey),
                  const SizedBox(height: 10),
                  Container(height: 12, width: 120, color: Colors.grey),
                  const SizedBox(height: 16),
                  Container(height: 38, width: double.infinity, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(24))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final hasFilter = _searchController.text.trim().isNotEmpty || _activeFilterCount > 0 || (isSelected != null && isSelected! > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 18),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFEDF0F1))),
      child: Column(
        children: [
          Lottie.asset("assets/animation/no_properties.json", height: 140, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _defaultPropertyImage(height: 120, width: 160, fit: BoxFit.contain)),
          const SizedBox(height: 10),
          Text(hasFilter ? 'No matching properties' : 'No properties yet', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            hasFilter ? 'Try changing your search or filters.' : 'Start by adding your first property listing.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.gray500, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 190,
            child: CustomizedButton(
              buttonColor: AppColors.primary,
              title: hasFilter ? 'Clear Filters' : 'Add Property',
              textColor: AppColors.white,
              onTap: () {
                if (hasFilter) {
                  _searchController.clear();
                  setState(() {
                    isSelected = 0;
                    _resetAdvancedFilters();
                  });
                  _applyFilters();
                } else {
                  _onAddProperty();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _propertyCard(Data property) {
    final title = (property.title ?? '').trim().isEmpty ? 'Untitled property' : property.title!;
    final location = (property.location ?? property.area ?? '').trim().isEmpty ? '-' : (property.location ?? property.area)!;
    final price = (property.price ?? '').toString().trim().isEmpty ? '-' : property.price.toString();
    final type = (property.type ?? '').trim().isEmpty ? '-' : property.type!;

    return GestureDetector(
      onTap: () => _openDetails(property),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  child: _buildPropertyMedia(property, height: 190, width: double.infinity),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(20)),
                    child: Text(type, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600)),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.currency_rupee_rounded, size: 12, color: Colors.white),
                        const SizedBox(width: 2),
                        Text(price, style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700, color: AppColors.blackColor)),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Image.asset(AppIcons.icLocation, height: 12, width: 12, fit: BoxFit.cover),
                      const SizedBox(width: 5),
                      Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.greyColor, fontWeight: FontWeight.w500))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFEFF2F2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _specItem(Icons.aspect_ratio_rounded, '${property.size ?? '-'} sqft'),
                      const SizedBox(width: 14),
                      _specItem(Icons.bed_outlined, '${property.format ?? '-'}'),
                      const Spacer(),
                      if ((property.category ?? '').isNotEmpty) _specItem(Icons.category_outlined, property.category!),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () => _openDetails(property),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(IconData icon, String text) {
    return Row(
      children: [Icon(icon, size: 15, color: AppColors.primary), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary))],
    );
  }

  void _openDetails(Data property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MyPropertyDetails(
              sizetype: property.sizeType ?? '',
              type: property.type ?? '',
              size: property.size ?? '',
              images: property.media ?? [],
              squarefeet: property.sizeType ?? '',
              companyname: property.title ?? '',
              price: property.price?.toString() ?? '',
              address: property.location ?? '',
              description: property.description ?? '',
              format: property.format ?? '',
              category: property.category ?? '',
              furnished: property.furnished ?? '',
              area: property.area ?? '',
              negotiable: "No",
              propertyid: property.sId ?? '',
              floor: property.floor ?? '',
            ),
      ),
    );
  }

  // ---------------------------------------------------------- FILTER BOTTOM SHEET

  void getBottomSheet() {
    final savedCategory = isCategoerySelected;
    final savedFloor = isFloorSelected;
    final savedFormat = isFormatSelected;
    final savedFurnished = isFurnished;
    final savedLower = _lowervalue;
    final savedUpper = _uppervalue;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (builder) {
        return StatefulBuilder(
          builder: (context, mystate) {
            String? categoryName = isCategoerySelected != null ? category[isCategoerySelected!] : null;

            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
                decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHeader(
                      mystate: mystate,
                      onReset: () {
                        mystate(() {
                          _resetAdvancedFilters();
                        });
                      },
                      onClose: () {
                        Navigator.pop(context);
                        setState(() {
                          isCategoerySelected = savedCategory;
                          isFloorSelected = savedFloor;
                          isFormatSelected = savedFormat;
                          isFurnished = savedFurnished;
                          _lowervalue = savedLower;
                          _uppervalue = savedUpper;
                        });
                      },
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _filterSection(
                              icon: Icons.home_work_outlined,
                              title: 'Category',
                              child: _chipWrap(items: category, selectedIndex: isCategoerySelected, onTap: (i) => mystate(() => isCategoerySelected = i)),
                            ),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeInOut,
                              child:
                                  categoryName == 'Bunglow'
                                      ? const SizedBox.shrink()
                                      : _filterSection(
                                        icon: Icons.stairs_outlined,
                                        title: 'Floor',
                                        child: _chipWrap(items: floor, selectedIndex: isFloorSelected, onTap: (i) => mystate(() => isFloorSelected = i)),
                                      ),
                            ),
                            _filterSection(icon: Icons.currency_rupee_rounded, title: 'Price Range', trailing: _priceBadge(mystate), child: _priceSlider(mystate)),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeInOut,
                              child:
                                  categoryName == 'Office'
                                      ? const SizedBox.shrink()
                                      : _filterSection(
                                        icon: Icons.bed_outlined,
                                        title: 'Format',
                                        child: _chipWrap(items: format, selectedIndex: isFormatSelected, onTap: (i) => mystate(() => isFormatSelected = i)),
                                      ),
                            ),
                            _filterSection(
                              icon: Icons.chair_outlined,
                              title: 'Furnished',
                              child: _chipWrap(items: furnished, selectedIndex: isFurnished, onTap: (i) => mystate(() => isFurnished = i)),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    _sheetFooter(
                      onApply: () {
                        Navigator.pop(context);
                        _applyFilters();
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
  }

  Widget _sheetHeader({required StateSetter mystate, required VoidCallback onReset, required VoidCallback onClose}) {
    return Column(
      children: [
        Container(margin: const EdgeInsets.only(top: 10), height: 4, width: 44, decoration: BoxDecoration(color: const Color(0xFFE0E4E4), borderRadius: BorderRadius.circular(10))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(color: const Color(0xFFE7F1EF), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 10),
              const Expanded(child: Text('Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.blackColor))),
              TextButton(
                onPressed: onReset,
                style: TextButton.styleFrom(minimumSize: Size.zero, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('Reset', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(color: const Color(0xFFF4F5F7), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close_rounded, size: 18, color: AppColors.gray500),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEFF2F2)),
      ],
    );
  }

  Widget _filterSection({required IconData icon, required String title, required Widget child, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.blackColor)),
              if (trailing != null) ...[const Spacer(), trailing],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _chipWrap({required List<String> items, required int? selectedIndex, required ValueChanged<int> onTap}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(items.length, (i) {
        final selected = selectedIndex == i;
        return GestureDetector(
          onTap: () => onTap(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE6EAEA)),
            ),
            child: Text(items[i], style: TextStyle(fontSize: 12.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? Colors.white : AppColors.gray500)),
          ),
        );
      }),
    );
  }

  Widget _priceBadge(StateSetter mystate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(20)),
      child: Text('₹${_formatNumber(_lowervalue)} - ₹${_formatNumber(_uppervalue)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
    );
  }

  // ----------------------------------------------------------- PRICE SLIDER
  // ✅ FIXED: removed `boxStyle` (not supported in your flutter_xlider version)
  Widget _priceSlider(StateSetter mystate) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: FlutterSlider(
        values: [_lowervalue, _uppervalue],
        rangeSlider: true,
        max: _maxPrice,
        min: _minPrice,
        step: const FlutterSliderStep(step: 1000),
        jump: true,
        trackBar: FlutterSliderTrackBar(
          activeTrackBarHeight: 6,
          inactiveTrackBarHeight: 6,
          inactiveTrackBar: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFFE6EAEA)),
          activeTrackBar: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        ),
        tooltip: FlutterSliderTooltip(alwaysShowTooltip: false, textStyle: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
        handler: FlutterSliderHandler(decoration: const BoxDecoration(), child: _sliderHandle()),
        rightHandler: FlutterSliderHandler(decoration: const BoxDecoration(), child: _sliderHandle()),
        onDragging: (handlerIndex, lowerValue, upperValue) {
          mystate(() {
            _lowervalue = lowerValue;
            _uppervalue = upperValue;
          });
        },
      ),
    );
  }

  Widget _sheetFooter({required VoidCallback onApply}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: Color(0xFFEFF2F2)))),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(Icons.check_rounded, size: 20), SizedBox(width: 8), Text('Apply Filters', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700))],
          ),
        ),
      ),
    );
  }

  Widget _sliderHandle() {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
    );
  }

  String _formatNumber(double v) {
    final n = v.toInt();
    if (n >= 1000) {
      final k = (n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1);
      return '$k K';
    }
    return '$n';
  }
}
