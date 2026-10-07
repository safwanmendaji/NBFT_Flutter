import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/services/api/subscription_api.dart';
import 'package:flutter_nobrokeragefortenants/models/subscription/subscription_model.dart';
import 'package:flutter_nobrokeragefortenants/services/user_property_storage.dart';
import 'package:flutter_nobrokeragefortenants/screens/user/subscription_screen.dart';
import 'package:flutter_nobrokeragefortenants/screens/property_details/user_property_details.dart';

import 'manage_subscription_screen.dart';

class UserHomeDashboard extends StatefulWidget {
  const UserHomeDashboard({super.key});

  @override
  State<UserHomeDashboard> createState() => _UserHomeDashboardState();
}

class _UserHomeDashboardState extends State<UserHomeDashboard> {
  final _searchController = TextEditingController();
  List<Data> properties = [];
  List<Data> visibleProperties = [];
  bool isLoading = true;
  SubscriptionStatus? _subscription;

  @override
  void initState() {
    super.initState();
    initCall();
  }

  initCall() async {
    _loadProperties();
    _loadSubscription();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties({Map<String, dynamic>? params}) async {
    try {
      final response = await Propertyapis.getSharedProperties(
        context: context,
        userId: Prefs.getString(LocalStrings.userid),
        params: params ?? {},
        // params: {'search': '', 'category': '', 'floor': '', 'priceRange': '', 'format': '', 'type': '', 'furnished': ''},
      );
      if (!mounted) return;
      setState(() {
        properties = response.data ?? [];
        visibleProperties = properties;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Assigned properties load failed: $error');
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadSubscription() async {
    try {
      final subscription = await SubscriptionApi.getMySubscription(context: context);
      if (mounted) setState(() => _subscription = subscription);
    } catch (_) {
      final start = DateTime.tryParse(Prefs.getString(LocalStrings.subscriptionStart));
      final end = DateTime.tryParse(Prefs.getString(LocalStrings.subscriptionEnd));
      final cachedPurpose = Prefs.getString(LocalStrings.subscriptionPurpose);
      final purpose =
          cachedPurpose.isNotEmpty
              ? cachedPurpose
              : Prefs.getBool(LocalStrings.subscribedCommercial, false) == true
              ? 'Commercial'
              : Prefs.getBool(LocalStrings.subscribedResidential, false) == true
              ? 'Residential'
              : '';
      final isRefunded = false;
      if (mounted && (start != null || end != null || purpose.isNotEmpty)) {
        setState(() => _subscription = SubscriptionStatus(startDate: start, endDate: end, isRefunded: isRefunded, propertyPurpose: purpose));
      }
    }
  }

  void _filterProperties(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    setState(() {
      visibleProperties =
          normalizedQuery.isEmpty
              ? properties
              : properties.where((property) {
                final searchableText = [property.title, property.location, property.area, property.category, property.format].whereType<String>().join(' ').toLowerCase();
                return searchableText.contains(normalizedQuery);
              }).toList();
    });
  }

  DateTime? get _planStart => _subscription?.startDate;
  DateTime? get _planExpiry => _subscription?.endDate;

  int? get _daysRemaining => _planExpiry?.difference(DateTime.now()).inDays;

  String get _planName {
    final purpose = _subscription?.propertyPurpose;
    return purpose == null || purpose.isEmpty ? 'Membership plan' : '$purpose plan';
  }

  String get _membershipStatus {
    if (_subscription == null) return 'NO PLAN';
    if (_subscription!.isRefunded) return 'REFUNDED';
    return _subscription!.isActive ? 'ACTIVE' : 'EXPIRED';
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _toggleWishlist(Data property) async {
    final id = property.sId;
    if (id == null) return;
    await UserPropertyStorage.toggle(UserPropertyStorage.wishlistKey, id);

    if (mounted) setState(() {});
  }

  Future<void> _toggleInterested(Data property) async {
    final id = property.sId;
    if (id == null) return;
    await UserPropertyStorage.toggle(UserPropertyStorage.interestedKey, id);
    await Propertyapis.toggleInterest(context: context, propertyId: property.sId?.toString() ?? "", interested: property.isInterested == true ? "Not Interested" : "Interested");
    await _loadProperties();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final name = Prefs.getString(LocalStrings.username, 'User');
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _greeting(name),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {
                
                    }),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
                      hintText: 'Search  properties',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xffeeeae3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xffeeeae3))),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xffeeeae3))),
                  child: const Icon(Icons.tune_rounded, size: 21, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadProperties,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    //const SizedBox(height: 18),
                    // _membershipCard(),
                    // const SizedBox(height: 18),
                    //_searchBar(),
                    //const SizedBox(height: 24),
                    _suggestedHeading(),
                    const SizedBox(height: 14),
                    _propertyList(_loadProperties),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _greeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hello, $name', style: const TextStyle(color: AppColors.primary, fontSize: 25, height: 1.15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        const Text('Welcome to your private curation', style: TextStyle(color: AppColors.gray500, fontSize: 13)),
      ],
    );
  }

  Widget _membershipCard() {
    final days = _daysRemaining;

    final isActive = _subscription?.isActive == true;

    final progress =
        days != null && _planStart != null && _planExpiry != null && _planExpiry!.difference(_planStart!).inSeconds > 0
            ? (DateTime.now().difference(_planStart!).inSeconds / _planExpiry!.difference(_planStart!).inSeconds).clamp(0.0, 1.0)
            : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xffffe9bd), Color(0xfffff0d1)]),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffffd98f), width: 1),
        boxShadow: [BoxShadow(color: const Color(0xff9B7A3A).withValues(alpha: .10), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // TOP SECTION
          // ============================================================
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 500;

              if (isSmall) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [_membershipStatusPill(), const SizedBox(width: 10), Expanded(child: _planPill())]),

                    const SizedBox(height: 12),

                    _planActions(),
                  ],
                );
              }

              return Row(children: [_membershipStatusPill(), const SizedBox(width: 12), Expanded(child: _planPill()), const SizedBox(width: 12), _planActions()]);
            },
          ),

          const SizedBox(height: 24),

          // ============================================================
          // PLAN INFO
          // ============================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Days
              Text(
                days == null ? '--' : '${days.clamp(0, 9999)}',
                style: const TextStyle(color: AppColors.primary, fontSize: 42, height: .95, fontWeight: FontWeight.w800, letterSpacing: -1.5),
              ),

              const SizedBox(width: 8),

              const Padding(
                padding: EdgeInsets.only(bottom: 3),
                child: Text('days remaining', style: TextStyle(color: Color(0xff303B3B), fontSize: 15, fontWeight: FontWeight.w500)),
              ),

              const Spacer(),

              // Expiry
              if (_planExpiry != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('VALID UNTIL', style: TextStyle(color: Color(0xff788080), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: .8)),
                    const SizedBox(height: 3),
                    Text(_formatDate(_planExpiry!), style: const TextStyle(color: Color(0xff303B3B), fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
            ],
          ),

          const SizedBox(height: 18),

          // ============================================================
          // PROGRESS
          // ============================================================
          if (days != null && isActive) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Plan validity', style: TextStyle(color: Color(0xff667171), fontSize: 11, fontWeight: FontWeight.w600)),

                Text('${(progress * 100).round()}% used', style: const TextStyle(color: Color(0xff667171), fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),

            const SizedBox(height: 7),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                minHeight: 9,
                backgroundColor: Colors.white.withValues(alpha: .75),
                value: progress,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_planStart == null ? '' : _formatDate(_planStart!), style: const TextStyle(color: Color(0xff7A8181), fontSize: 10)),
                Text(_planExpiry == null ? '' : _formatDate(_planExpiry!), style: const TextStyle(color: Color(0xff7A8181), fontSize: 10)),
              ],
            ),
          ],

          // ============================================================
          // INACTIVE STATE
          // ============================================================
          if (!isActive) ...[
            const SizedBox(height: 4),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .55), borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 17, color: Color(0xff747979)),
                  SizedBox(width: 8),
                  Expanded(child: Text('Your membership is currently inactive.', style: TextStyle(color: Color(0xff626868), fontSize: 12, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _membershipStatusPill() {
    final isActive = _subscription?.isActive == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .15), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Membership', style: TextStyle(color: Colors.white.withValues(alpha: .85), fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Text(isActive ? 'ACTIVE' : 'INACTIVE', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: .3)),
        ],
      ),
    );
  }

  Widget _planPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: .75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan', style: TextStyle(color: Color(0xff718080), fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Text(_planName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _planActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit Plan
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
          },
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                SizedBox(width: 4),
                Icon(Icons.edit_outlined, size: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),

        const SizedBox(width: 4),

        // Manage Plan
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionDetailsScreen()));
          },
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Manage', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: color == AppColors.primary ? Colors.white : AppColors.primary, fontSize: 10),
          children: [TextSpan(text: '$title\n'), TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w700))],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xffeeeae3))),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProperties,
              decoration: const InputDecoration(
                icon: Icon(Icons.search, size: 20, color: AppColors.gray500),
                hintText: 'Search properties or locations',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.gray500),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showFilterBottomSheet(),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xffeeeae3))),
            child: const Icon(Icons.tune_rounded, size: 21, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) {
        return _PropertyFilterBottomSheet(
          onApply: (filters) {
            Navigator.pop(context, filters);
            // Use your filters here
            _loadProperties(params: filters);
          },
        );
      },
    );
  }

  Widget _suggestedHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(child: Text('Admin suggested for you', style: TextStyle(color: AppColors.primary, fontSize: 21, fontWeight: FontWeight.w700))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
          child: Text('${visibleProperties.length} listings', style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ],
    );
  }

  Widget _propertyList(Function onRefresh) {
    if (isLoading) {
      return const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: CircularProgressIndicator()));
    }
    if (visibleProperties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13)),
        child: Column(
          children: [
            const Icon(Icons.home_work_outlined, size: 50, color: AppColors.secondary),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty ? 'No properties available yet' : 'No properties match your search',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final data = properties[index];
        //return PropertyCard();
        return _propertyCard(data, onRefresh);
      },
    );
    //return Column(children: visibleProperties.take(6).map(_propertyCard).toList());
  }

  // Widget _propertyCard(Data property, Function onRefresh) {
  //   final imagePath = property.media?.isNotEmpty == true ? property.media!.first.path : null;
  //   final title = property.title ?? 'Untitled property';
  //   final location = property.location ?? property.area ?? 'Location unavailable';
  //   final price = property.price == null ? 'Price unavailable' : '₹${property.price}';
  //   return InkWell(
  //     onTap: () async {
  //       await Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) {
  //             return UserPropertyDetails(property: property);
  //           },
  //         ),
  //       );
  //       onRefresh();
  //     },
  //     child: Container(
  //       margin: const EdgeInsets.only(bottom: 16),
  //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(13), boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 8)]),
  //       clipBehavior: Clip.antiAlias,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           SizedBox(
  //             height: 180,
  //             width: double.infinity,
  //             child: Stack(
  //               fit: StackFit.expand,
  //               children: [
  //                 imagePath == null
  //                     ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
  //                     : CachedNetworkImage(imageUrl: '${AppEndpoints.imgUrl}$imagePath', fit: BoxFit.cover, errorWidget: (_, __, ___) => Image.asset(AppIcons.icProperty, fit: BoxFit.cover)),
  //                 Positioned(top: 12, left: 12, child: _imageTag(property.status ?? 'Available', AppColors.primary)),
  //                 Positioned(top: 12, right: 12, child: _imageTag('Admin verified', Colors.white)),
  //                 Positioned(
  //                   bottom: 12,
  //                   right: 12,
  //                   top: 40,
  //                   child: GestureDetector(
  //                     onTap: () => _toggleInterested(property),
  //                     child: CircleAvatar(
  //                       radius: 16,
  //                       backgroundColor: Colors.white.withValues(alpha: .9),
  //                       child: Icon(UserPropertyStorage.ids(UserPropertyStorage.interestedKey).contains(property.sId) ? Icons.favorite : Icons.favorite_border, size: 17),
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   bottom: 12,
  //                   right: 12,
  //                   child: GestureDetector(
  //                     onTap: () => _toggleWishlist(property),
  //                     child: CircleAvatar(
  //                       radius: 16,
  //                       backgroundColor: Colors.white.withValues(alpha: .9),
  //                       child: Icon(UserPropertyStorage.ids(UserPropertyStorage.wishlistKey).contains(property.sId) ? Icons.bookmark : Icons.bookmark_border, size: 19, color: AppColors.primary),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(price, style: const TextStyle(fontSize: 25, color: AppColors.primary, fontWeight: FontWeight.w700)),
  //                 Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: AppColors.primary, fontWeight: FontWeight.w600)),
  //                 const SizedBox(height: 5),
  //                 Row(
  //                   children: [
  //                     const Icon(Icons.location_on_outlined, size: 15, color: AppColors.gray500),
  //                     const SizedBox(width: 3),
  //                     Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 10),
  //                 Wrap(
  //                   spacing: 6,
  //                   runSpacing: 6,
  //                   children: [
  //                     _detailChip(Icons.king_bed_outlined, property.format ?? 'Details unavailable'),
  //                     _detailChip(Icons.square_foot, property.size ?? 'Area unavailable'),
  //                     _detailChip(Icons.remove_red_eye_outlined, 'See view'),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 11),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 42,
  //                   child: OutlinedButton.icon(
  //                     onPressed: () => _toggleInterested(property),
  //                     icon: Icon(UserPropertyStorage.ids(UserPropertyStorage.interestedKey).contains(property.sId) ? Icons.favorite : Icons.favorite_border, size: 17),
  //                     label: const Text('Mark as interested', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
  //                     style: OutlinedButton.styleFrom(
  //                       foregroundColor: AppColors.primary,
  //                       side: const BorderSide(color: AppColors.primary),
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                     ),
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 SizedBox(
  //                   width: double.infinity,
  //                   height: 42,
  //                   child: ElevatedButton.icon(
  //                     onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserPropertyDetails(property: property))),

  //                     icon: const Icon(Icons.arrow_forward, size: 17),
  //                     label: const Text('View details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
  //                     iconAlignment: IconAlignment.end,
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: const Color(0xff1e3034),
  //                       foregroundColor: Colors.white,
  //                       elevation: 0,
  //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _propertyCard(Data property, Function onRefresh) {
    final imagePath = property.media?.isNotEmpty == true ? property.media!.first.path : null;

    final title = property.title ?? 'Untitled property';

    final location = property.location ?? property.area ?? 'Location unavailable';

    final price = property.price == null ? 'Price unavailable' : '₹${property.price}';

    final isInterested = property.isInterested ?? false;

    final isWishlisted = UserPropertyStorage.ids(UserPropertyStorage.wishlistKey).contains(property.sId);

    return InkWell(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (_) => UserPropertyDetails(property: property)));

        onRefresh();
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .07), blurRadius: 24, offset: const Offset(0, 8))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // IMAGE SECTION
            // ============================================================
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Property Image
                  imagePath == null
                      ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
                      : CachedNetworkImage(
                        imageUrl: '${AppEndpoints.imgUrl}$imagePath',
                        fit: BoxFit.cover,
                        placeholder: (context, url) {
                          return Image.asset(AppIcons.icProperty, fit: BoxFit.cover);
                        },
                        errorWidget: (_, __, ___) {
                          return Image.asset(AppIcons.icProperty, fit: BoxFit.cover);
                        },
                      ),

                  // ======================================================
                  // IMAGE GRADIENT
                  // ======================================================
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black.withValues(alpha: .12), Colors.transparent, Colors.black.withValues(alpha: .25)],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // ======================================================
                  // ACTIVE BADGE
                  // ======================================================
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                          const SizedBox(width: 7),
                          Text(property.status ?? 'Available', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),

                  // ======================================================
                  // VERIFIED BADGE
                  // ======================================================
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .95), borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text('Admin verified', style: TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),

                  // ======================================================
                  // FAVORITE + BOOKMARK
                  // ======================================================
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Column(
                      children: [
                        // Favorite
                        GestureDetector(
                          onTap: () {
                            _toggleInterested(property);
                          },
                          child: _floatingActionButton(
                            icon: isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            iconColor: isInterested ? Colors.redAccent : AppColors.primary,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Bookmark
                        // GestureDetector(
                        //   onTap: () {
                        //     _toggleWishlist(property);
                        //   },
                        //   child: _floatingActionButton(icon: isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, iconColor: AppColors.primary),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ============================================================
            // CONTENT
            // ============================================================
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, color: Color(0xff243635), fontWeight: FontWeight.w700)),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.gray500),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.gray500, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(price, style: const TextStyle(fontSize: 16, height: 1.1, color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  const SizedBox(height: 16),

                  // ========================================================
                  // PROPERTY FEATURES
                  // ========================================================
                  Row(
                    children: [
                      Expanded(child: _modernDetailChip(icon: Icons.king_bed_outlined, text: property.format ?? 'N/A')),

                      const SizedBox(width: 8),

                      Expanded(child: _modernDetailChip(icon: Icons.square_foot_rounded, text: property.size ?? 'N/A')),

                      const SizedBox(width: 8),

                      Expanded(child: _modernDetailChip(icon: Icons.remove_red_eye_outlined, text: 'See view')),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ========================================================
                  // ACTION BUTTONS
                  // ========================================================
                  Row(
                    children: [
                      // Interested
                      // Expanded(
                      //   child: SizedBox(
                      //     height: 48,
                      //     child: OutlinedButton.icon(
                      //       onPressed: () {
                      //         _toggleInterested(property);
                      //       },
                      //       icon: Icon(isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 19),
                      //       label: Text(isInterested ? 'Interested' : 'Interested', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      //       style: OutlinedButton.styleFrom(
                      //         foregroundColor: AppColors.primary,
                      //         side: BorderSide(color: AppColors.primary, width: 1.4),
                      //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(width: 10),

                      // View Details
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => UserPropertyDetails(property: property)));

                              onRefresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff193A3A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                SizedBox(width: 7),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
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

  Widget _floatingActionButton({required IconData icon, required Color iconColor}) {
    return Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .95),
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .12), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  Widget _modernDetailChip({required IconData icon, required String text}) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xffF2F6F5), borderRadius: BorderRadius.circular(13)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xff315E5A), fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _imageTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: .92), borderRadius: BorderRadius.circular(14)),
      child: Text(text, style: TextStyle(color: color == Colors.white ? AppColors.primary : Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xfff1f3f2), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// STATUS BADGE
// ─────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color backgroundColor;

  const _StatusBadge({required this.icon, required this.text, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.white),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────
// ROUND ACTION BUTTON
// ─────────────────────────────────────

class _RoundButton extends StatelessWidget {
  final IconData icon;

  const _RoundButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      width: 46,
      decoration: BoxDecoration(color: Colors.white.withOpacity(.96), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 12)]),
      child: Icon(icon, color: const Color(0xff246B63), size: 22),
    );
  }
}

// ─────────────────────────────────────
// FEATURE CHIP
// ─────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: const Color(0xffF2F6F5), borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xff246B63)),
            const SizedBox(width: 6),
            Flexible(child: Text(text, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xff315E5A), fontSize: 13, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }
}

class _PropertyFilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic> filters) onApply;

  const _PropertyFilterBottomSheet({required this.onApply});

  @override
  State<_PropertyFilterBottomSheet> createState() => _PropertyFilterBottomSheetState();
}

class _PropertyFilterBottomSheetState extends State<_PropertyFilterBottomSheet> {
  // ============================================================
  // THEME
  // ============================================================

  static const Color primary = AppColors.primary;

  static const Color background = Color(0xffF8F8F6);

  static const Color beige = Color(0xffC2B294);

  static const Color lightBeige = Color(0xffF5F0E6);

  static const Color textColor = Color(0xff304343);

  static const Color borderColor = Color(0xff294F4F);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _minPriceController = TextEditingController();

  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _sizeTypeController = TextEditingController();

  // ============================================================
  // SELECTED VALUES
  // ============================================================

  String? _selectedPropertyType;

  String? _selectedFloor;

  String? _selectedSizeType;

  String? _selectedFurnished;

  // ============================================================
  // OPTIONS
  // ============================================================

  final List<String> _propertyTypes = ['House', 'Bungalow', 'Flat', 'Office', 'Shop'];

  final List<String> _floorTypes = ['Top (Nineth and Above)', 'Middle (Fourth to Nineth floor)', 'Bottom (Ground to Fourth floor)'];

  final List<String> _sizeTypes = ['sqft', 'Vigha', 'SqYard'];

  final List<String> _furnishedTypes = ['Unfurnished', 'Furnished', 'Semi-furnished'];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();

    super.dispose();
  }

  // ============================================================
  // PROPERTY TYPE CHANGE
  // ============================================================

  void _selectPropertyType(String type) {
    setState(() {
      _selectedPropertyType = type;

      // Hide/reset floor for House & Bungalow
      if (type == 'House' || type == 'Bungalow') {
        _selectedFloor = null;
      }
    });
  }

  // ============================================================
  // APPLY
  // ============================================================

  void _applyFilters() {
    final filters = {
      'minPrice': _minPriceController.text.trim(),
      'maxPrice': _maxPriceController.text.trim(),
      'propertyType': _selectedPropertyType,
      'floor': _selectedFloor,
      'sizeType': _selectedSizeType,
      'furnished': _selectedFurnished,
    };

    widget.onApply(filters);
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clearFilters() {
    setState(() {
      _minPriceController.clear();
      _maxPriceController.clear();

      _selectedPropertyType = null;
      _selectedFloor = null;
      _selectedSizeType = null;
      _selectedFurnished = null;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .90,
      minChildSize: .55,
      maxChildSize: .96,
      expand: false,
      snap: true,
      snapSizes: const [.90, .96],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(color: background, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(
            children: [
              // ======================================================
              // HANDLE
              // ======================================================
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(20)),
              ),

              // ======================================================
              // HEADER
              // ======================================================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: primary.withValues(alpha: .10), shape: BoxShape.circle),
                      child: const Icon(Icons.tune_rounded, color: primary, size: 20),
                    ),

                    const SizedBox(width: 11),

                    const Expanded(child: Text('Filters', style: TextStyle(color: textColor, fontSize: 21, fontWeight: FontWeight.w800))),

                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.close_rounded, color: Color(0xff8B9393), size: 24)),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xffE5E4DF)),

              // ======================================================
              // CONTENT
              // ======================================================
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==================================================
                      // PRICE
                      // ==================================================
                      _sectionTitle('Price Range', Icons.payments_outlined),

                      const SizedBox(height: 13),

                      Row(
                        children: [
                          Expanded(child: _priceField(controller: _minPriceController, label: 'Min Price', hint: '₹0', prefix: "₹ ")),

                          const SizedBox(width: 12),

                          Expanded(child: _priceField(controller: _maxPriceController, label: 'Max Price', hint: '₹1,00,00,000', prefix: "₹ ")),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // PROPERTY TYPE
                      // ==================================================
                      _sectionTitle('Property Type', Icons.home_work_outlined),

                      const SizedBox(height: 12),

                      _chipWrap(items: _propertyTypes, selected: _selectedPropertyType, onSelected: _selectPropertyType),

                      // ==================================================
                      // FLOOR
                      // ==================================================
                      if (_selectedPropertyType != 'House' && _selectedPropertyType != 'Bungalow') ...[
                        const SizedBox(height: 24),

                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionTitle('Floor', Icons.layers_outlined),

                              const SizedBox(height: 12),

                              _chipWrap(
                                items: _floorTypes,
                                selected: _selectedFloor,
                                onSelected: (value) {
                                  setState(() {
                                    _selectedFloor = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

                      // ==================================================
                      // SIZE TYPE
                      // ==================================================
                      const SizedBox(height: 24),

                      _sectionTitle('Size Type', Icons.square_foot_rounded),

                      const SizedBox(height: 12),

                      _chipWrap(
                        items: _sizeTypes,
                        selected: _selectedSizeType,
                        onSelected: (value) {
                          setState(() {
                            _selectedSizeType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_selectedSizeType != null) _priceField(controller: _sizeTypeController, label: 'Enter ${_selectedSizeType ?? ""}', hint: ''),

                      // ==================================================
                      // FURNISHED
                      // ==================================================
                      const SizedBox(height: 24),

                      _sectionTitle('Furnished', Icons.weekend_outlined),

                      const SizedBox(height: 12),

                      _chipWrap(
                        items: _furnishedTypes,
                        selected: _selectedFurnished,
                        onSelected: (value) {
                          setState(() {
                            _selectedFurnished = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ======================================================
              // BOTTOM BUTTONS
              // ======================================================
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).viewPadding.bottom),
                decoration: BoxDecoration(color: background, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .08), blurRadius: 15, offset: const Offset(0, -4))]),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _clearFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            backgroundColor: const Color(0xffE9EAED),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Clear', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _applyFilters,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Icon(Icons.check_rounded, size: 19), SizedBox(width: 7), Text('Apply Filters', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800))],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [Icon(icon, size: 18, color: primary), const SizedBox(width: 7), Text(title, style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800))],
    );
  }

  // ============================================================
  // PRICE FIELD
  // ============================================================

  Widget _priceField({required TextEditingController controller, required String label, required String hint, String prefix = ''}) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixStyle: const TextStyle(color: primary, fontWeight: FontWeight.w700),
        labelStyle: const TextStyle(color: Color(0xff737D7D), fontSize: 12),
        hintStyle: const TextStyle(color: Color(0xffA4AAAA), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xffD8D8D2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: primary, width: 1.5)),
      ),
    );
  }

  // ============================================================
  // CHIP WRAP
  // ============================================================

  Widget _chipWrap({required List<String> items, required String? selected, required Function(String value) onSelected}) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          items.map((item) {
            final isSelected = selected == item;

            return GestureDetector(
              onTap: () => onSelected(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: isSelected ? Colors.white : Colors.black, width: isSelected ? 1.6 : 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[const Icon(Icons.check_rounded, color: Colors.white, size: 17), const SizedBox(width: 5)],

                    Text(item, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
