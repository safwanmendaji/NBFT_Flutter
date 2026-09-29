import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_constants.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/font_size.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/screens/property_details/property_details.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/services/api/auth_api.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_button.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_form_field.dart';
import 'package:flutter_nobrokeragefortenants/widgets/customize_text_widget.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final _searchController = TextEditingController();

  double priceRange = 10000.0;
  final List<String> floor = [
    "Ground floor",
    "First floor",
    "Second",
    "Third",
    "Any",
  ];
  final List<String> category = [
    "Flat",
    "Bunglow",
    "Plant House",
    "Office",
    "Shop",
  ];
  final List<String> format = ["1 BHK", "2 BHK", "3 BHK", "4 BHK"];
  final List<String> furnished = ["Fully", "Semi", "Unfurnished"];
  final List<String> option = ["All", "Commercial", "Residential"];

  List<Data> yourproperty = [];

  int isSelected = 0;
  int isFloorSelected = 0;
  int isCategoerySelected = 0;
  int isFormatSelected = 0;
  int isFurnished = 0;

  String? selectedSize;
  String selectedStatus = 'all';
  Map<String, int> interestCounts = {};

  bool _isLoading = true;

  // ------------------------------------------------------------------ HELPERS

  List<Data> get _allProperties => yourproperty;

  List<Data> _propertiesForStatus(String status) {
    if (status == 'all') return _allProperties;
    return _allProperties.where((property) {
      final value = (property.status ?? '').toLowerCase();
      return value == status;
    }).toList();
  }

  int get _activeFilterCount {
    int count = 0;
    if (isCategoerySelected != 0) count++;
    if (isFloorSelected != 0) count++;
    if (isFormatSelected != 0) count++;
    if (isFurnished != 0) count++;
    if (priceRange != 10000.0) count++;
    if (selectedSize != null) count++;
    return count;
  }

  // ------------------------------------------------------------------ API

  _poreprtiesApi({int? from}) async {
    if (from == 0 && mounted) setState(() => _isLoading = true);

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
          isShowProgress: false,
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

            log("APi Success");
            yourproperty = response.data ?? [];

            _brokerLeadsApi();
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          } else {
            if (mounted) setState(() => _isLoading = false);
          }
        })
        .catchError((error) {
          yourproperty = [];
          if (mounted) setState(() => _isLoading = false);
          ErrorManager().showErrorDialogue(e: error, context: context);
        })
        .onError((error, stacktrace) {
          if (mounted) setState(() => _isLoading = false);
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
    super.initState();
    Future.delayed(Durations.medium1, () {
      _poreprtiesApi(from: 0);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------- BUILD

  @override
  Widget build(BuildContext context) {
    getScreenSize(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topBar(),
            _statusTabs(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Row(
                children: [
                  Expanded(child: _getSearchbar()),
                  const SizedBox(width: 10),
                  _getFilter(),
                ],
              ),
            ),
            Expanded(child: _buildList()),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- TOP BAR

  Widget _topBar() {
    final total = _allProperties.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.home_work_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Properties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total ${total == 1 ? "listing" : "listings"}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- STATUS TABS

  Widget _statusTabs() {
    final tabs = [
      {'label': 'All', 'status': 'all'},
      {'label': 'Active', 'status': 'active'},
      {'label': 'Inactive', 'status': 'inactive'},
      {'label': 'Draft', 'status': 'draft'},
    ];
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = tab['status'] == selectedStatus;
          final count = _propertiesForStatus(tab['status']!).length;
          return _statusChip(
            label: tab['label']!,
            count: count,
            selected: selected,
            onTap: () => setState(() => selectedStatus = tab['status']!),
          );
        },
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE6EAEA),
          ),
          boxShadow:
              selected
                  ? const [
                    BoxShadow(
                      color: Color(0x1A1F4F4A),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : AppColors.gray500,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color:
                    selected
                        ? Colors.white.withValues(alpha: 0.22)
                        : const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- SEARCH

  Widget _getSearchbar() => Container(
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE6EAEA)),
      boxShadow: const [BoxShadow(color: Color(0x07000000), blurRadius: 10)],
    ),
    child: PrimaryTextFeild(
      textInputAction: TextInputAction.search,
      hintText: 'Search properties...',
      hintColor: const Color(0xFFA1A9B8),
      controller: _searchController,
      onfeildSubmitted: (value) {
        setState(() => _poreprtiesApi(from: 2));
      },
      prefixIcon: AppIcons.icSearch,
      prefixiconcolor: const Color(0xFFA1A9B8),
    ),
  );

  // ---------------------------------------------------------------- FILTER

  Widget _getFilter() => GestureDetector(
    behavior: HitTestBehavior.translucent,
    onTap: _getBottomSheet,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1FDFA24A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(
                AppIcons.icFilter,
                height: 18,
                width: 18,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 8),
              getTextWidget(
                title: 'Filter',
                textFontSize: AppFonts.size14,
                textFontWeight: AppFonts.bold,
                textColor: AppColors.white,
              ),
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
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                '$_activeFilterCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    ),
  );

  // ---------------------------------------------------------------- LIST

  Widget _buildList() {
    if (_isLoading) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => _shimmerCard(),
      );
    }

    final list = _propertiesForStatus(selectedStatus);

    if (list.isEmpty) {
      return _emptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _propertyRow(list[index])
            .animate()
            .fade(duration: 500.ms, delay: (index * 60).ms)
            .slideY(begin: 0.12, end: 0, curve: Curves.easeOut);
      },
    );
  }

  Widget _shimmerCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            width: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEDF0F1),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 150,
                  color: const Color(0xFFEDF0F1),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11,
                  width: 100,
                  color: const Color(0xFFEDF0F1),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 14,
                  width: 90,
                  color: const Color(0xFFEDF0F1),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 10,
                  width: 160,
                  color: const Color(0xFFEDF0F1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    final hasFilter =
        _searchController.text.trim().isNotEmpty || _activeFilterCount > 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AppIcons.icNoPropertyImage,
              width: screenSize!.width * 0.6,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => Container(
                    height: 140,
                    width: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF1F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              hasFilter
                  ? 'No matching properties'
                  : 'No properties in ${selectedStatus == "all" ? "this list" : selectedStatus}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilter
                  ? 'Try adjusting your search or filters.'
                  : 'Add a property or switch to a different tab.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
            if (hasFilter) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 190,
                child: CustomizedButton(
                  buttonColor: AppColors.primary,
                  title: 'Clear Filters',
                  textColor: AppColors.white,
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      isSelected = 0;
                      isFloorSelected = 0;
                      isCategoerySelected = 0;
                      isFormatSelected = 0;
                      isFurnished = 0;
                      priceRange = 10000.0;
                      selectedSize = null;
                    });
                    _poreprtiesApi(from: 0);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- CARD

  Widget _propertyRow(Data property) {
    final imagePath =
        property.media?.isNotEmpty == true ? property.media!.first.path : null;
    final status =
        property.status?.isNotEmpty == true ? property.status! : 'Active';
    final interestCount = interestCounts[property.sId] ?? 0;

    final statusColor = _statusColor(status);

    return GestureDetector(
      onTap: () => _openProperty(property),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFF2F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Image --------
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      imagePath == null || imagePath.trim().isEmpty
                          ? _defaultImage()
                          : CachedNetworkImage(
                            imageUrl: '${AppEndpoints.imgUrl}$imagePath',
                            width: 118,
                            height: 118,
                            fit: BoxFit.cover,
                            placeholder:
                                (_, __) => Container(
                                  width: 118,
                                  height: 118,
                                  color: const Color(0xFFEDF0F1),
                                ),
                            errorWidget: (_, __, ___) => _defaultImage(),
                          ),
                ),
                // Interest badge (eye)
                if (interestCount > 0)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility_outlined,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '$interestCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // -------- Details --------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          property.title ?? 'Untitled property',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Location
                  Row(
                    children: [
                      Image.asset(
                        AppIcons.icLocation,
                        height: 11,
                        width: 11,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location ?? property.area ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.gray500,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Icon(
                        Icons.currency_rupee_rounded,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      Text(
                        _formatPrice(property.price),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        '/ month',
                        style: TextStyle(
                          color: AppColors.gray500,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chips row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if ((property.format ?? '').isNotEmpty)
                        _miniChip(Icons.bed_outlined, property.format!),
                      if ((property.furnished ?? '').isNotEmpty)
                        _miniChip(Icons.chair_outlined, property.furnished!),
                      if ((property.size ?? property.area ?? '')
                          .toString()
                          .isNotEmpty)
                        _miniChip(
                          Icons.square_foot,
                          '${property.size ?? property.area}',
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

  Widget _defaultImage() {
    return Container(
      width: 118,
      height: 118,
      color: const Color(0xFFEDF1F0),
      alignment: Alignment.center,
      child: const Icon(
        Icons.apartment_rounded,
        size: 44,
        color: AppColors.primary,
      ),
    );
  }

  Widget _miniChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.gray500),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.gray500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF2E9E5B);
      case 'inactive':
        return const Color(0xFFD9534F);
      case 'draft':
        return const Color(0xFFC68A2E);
      default:
        return AppColors.primary;
    }
  }

  String _formatPrice(dynamic price) {
    final v = int.tryParse(price?.toString() ?? '') ?? 0;
    return NumberFormat.decimalPattern('en_IN').format(v);
  }

  // -------------------------------------------------------- OPEN DETAILS

  void _openProperty(Data property) async {
    final result = await Navigator.push(
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

    if (result != null) {
      await _poreprtiesApi();
    }
  }

  // ---------------------------------------------------------- BOTTOM SHEET

  void _getBottomSheet() {
    final savedFloor = isFloorSelected;
    final savedCat = isCategoerySelected;
    final savedFormat = isFormatSelected;
    final savedFurnished = isFurnished;
    final savedPrice = priceRange;
    final savedSize = selectedSize;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (builder) {
        return StatefulBuilder(
          builder: (context, mystate) {
            return SafeArea(
              top: false,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.88,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sheetHeader(
                      mystate: mystate,
                      onReset: () {
                        mystate(() {
                          isFloorSelected = 0;
                          isCategoerySelected = 0;
                          isFormatSelected = 0;
                          isFurnished = 0;
                          priceRange = 10000.0;
                          selectedSize = null;
                        });
                      },
                      onClose: () {
                        Navigator.pop(context);
                        setState(() {
                          isFloorSelected = savedFloor;
                          isCategoerySelected = savedCat;
                          isFormatSelected = savedFormat;
                          isFurnished = savedFurnished;
                          priceRange = savedPrice;
                          selectedSize = savedSize;
                        });
                      },
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category
                            _filterSection(
                              icon: Icons.home_work_outlined,
                              title: 'Category',
                              child: _chipWrap(
                                items: category,
                                selectedIndex: isCategoerySelected,
                                onTap:
                                    (i) =>
                                        mystate(() => isCategoerySelected = i),
                              ),
                            ),

                            // Floor
                            _filterSection(
                              icon: Icons.stairs_outlined,
                              title: 'Floor',
                              child: _chipWrap(
                                items: floor,
                                selectedIndex: isFloorSelected,
                                onTap:
                                    (i) => mystate(() => isFloorSelected = i),
                              ),
                            ),

                            // Price
                            _filterSection(
                              icon: Icons.currency_rupee_rounded,
                              title: 'Price Range',
                              trailing: _priceBadge(),
                              child: _priceSlider(mystate),
                            ),

                            // Format
                            _filterSection(
                              icon: Icons.bed_outlined,
                              title: 'Format',
                              child: _chipWrap(
                                items: format,
                                selectedIndex: isFormatSelected,
                                onTap:
                                    (i) => mystate(() => isFormatSelected = i),
                              ),
                            ),

                            // Size type
                            _filterSection(
                              icon: Icons.straighten_rounded,
                              title: 'Size Type',
                              child: _chipWrap(
                                items: const ["Square foot", "Square Yard"],
                                selectedIndex:
                                    selectedSize == null
                                        ? null
                                        : (selectedSize == "Square foot"
                                            ? 0
                                            : 1),
                                onTap:
                                    (i) => mystate(() {
                                      selectedSize =
                                          i == 0
                                              ? "Square foot"
                                              : "Square Yard";
                                    }),
                              ),
                            ),

                            // Furnished
                            _filterSection(
                              icon: Icons.chair_outlined,
                              title: 'Furnished',
                              child: _chipWrap(
                                items: furnished,
                                selectedIndex: isFurnished,
                                onTap: (i) => mystate(() => isFurnished = i),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    _sheetFooter(
                      onApply: () {
                        Navigator.pop(context);
                        _poreprtiesApi(from: 1);
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

  Widget _sheetHeader({
    required StateSetter mystate,
    required VoidCallback onReset,
    required VoidCallback onClose,
  }) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          height: 4,
          width: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE0E4E4),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
          child: Row(
            children: [
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F1EF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blackColor,
                  ),
                ),
              ),
              TextButton(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: AppColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEFF2F2)),
      ],
    );
  }

  Widget _filterSection({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              if (trailing != null) ...[const Spacer(), trailing],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _chipWrap({
    required List<String> items,
    required int? selectedIndex,
    required ValueChanged<int> onTap,
  }) {
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
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFE6EAEA),
              ),
            ),
            child: Text(
              items[i],
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.gray500,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _priceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '₹${_formatNumber(1000)} - ₹${_formatNumber(priceRange)}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _priceSlider(StateSetter mystate) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: const Color(0xFFE6EAEA),
          thumbColor: AppColors.white,
          overlayColor: AppColors.primary.withValues(alpha: 0.15),
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(
            enabledThumbRadius: 11,
            elevation: 3,
          ),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
        ),
        child: Slider(
          value: priceRange,
          min: 1000.0,
          max: 50000.0,
          divisions: 49,
          label: '₹${priceRange.round()}',
          onChanged: (double value) {
            mystate(() {
              priceRange = value;
            });
          },
        ),
      ),
    );
  }

  Widget _sheetFooter({required VoidCallback onApply}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: Color(0xFFEFF2F2))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'Apply Filters',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
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
