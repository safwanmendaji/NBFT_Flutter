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

  Future<void> _loadProperties() async {
    print("_loadProperties");
    try {
      final response = await Propertyapis.getSharedProperties(context: context, userId: Prefs.getString(LocalStrings.userid));
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
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final name = Prefs.getString(LocalStrings.username, 'User');
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      body: Column(
        children: [
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
                    _greeting(name),
                    const SizedBox(height: 18),
                    _membershipCard(),
                    const SizedBox(height: 18),
                    _searchBar(),
                    const SizedBox(height: 24),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xffffe9bd), borderRadius: BorderRadius.circular(13)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusPill('Membership', _membershipStatus, AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: _statusPill('Plan', _planName, const Color(0xfff8f0e2))),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
                child: const Text('Manage plan', style: TextStyle(color: AppColors.primary, fontSize: 12, decoration: TextDecoration.underline)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(days == null ? '--' : '${days.clamp(0, 9999)}', style: const TextStyle(color: AppColors.primary, fontSize: 25, fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              const Text('days remaining', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Text(_planExpiry == null ? 'Plan dates unavailable' : 'Valid till ${_formatDate(_planExpiry!)}', style: const TextStyle(fontSize: 12)),
            ],
          ),
          if (days != null && _subscription?.isActive == true) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 7,
                backgroundColor: Color(0xfff6f0e5),
                value: _planStart != null && _planExpiry != null ? (DateTime.now().difference(_planStart!).inSeconds / _planExpiry!.difference(_planStart!).inSeconds).clamp(0.0, 1.0) : 0,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ],
      ),
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
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xffeeeae3))),
          child: const Icon(Icons.tune_rounded, size: 21, color: AppColors.primary),
        ),
      ],
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
      shrinkWrap: true,
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final data = properties[index];
        return PropertyCard();
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

    final isInterested = UserPropertyStorage.ids(UserPropertyStorage.interestedKey).contains(property.sId);

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
              height: 215,
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
                          child: _floatingActionButton(icon: isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded, iconColor: isInterested ? Colors.redAccent : AppColors.primary),
                        ),

                        const SizedBox(height: 8),

                        // Bookmark
                        GestureDetector(
                          onTap: () {
                            _toggleWishlist(property);
                          },
                          child: _floatingActionButton(icon: isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, iconColor: AppColors.primary),
                        ),
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
                  // ========================================================
                  // PRICE
                  // ========================================================

                  Text(price, style: const TextStyle(fontSize: 28, height: 1.1, color: AppColors.primary, fontWeight: FontWeight.w800, letterSpacing: -.5)),

                  const SizedBox(height: 6),

                  // ========================================================
                  // TITLE
                  // ========================================================
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, color: Color(0xff243635), fontWeight: FontWeight.w700)),

                  const SizedBox(height: 7),

                  // ========================================================
                  // LOCATION
                  // ========================================================
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: AppColors.gray500),
                      const SizedBox(width: 5),
                      Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.gray500, fontWeight: FontWeight.w500))),
                    ],
                  ),

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
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _toggleInterested(property);
                            },
                            icon: Icon(isInterested ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 19),
                            label: Text(isInterested ? 'Interested' : 'Interested', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: BorderSide(color: AppColors.primary, width: 1.4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ),

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
                              children: [Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), SizedBox(width: 7), Icon(Icons.arrow_forward_rounded, size: 18)],
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
      height: 42,
      width: 42,
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
        children: [Icon(icon, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600))],
      ),
    );
  }
}

class PropertyCard extends StatelessWidget {
  const PropertyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─────────────────────────────
          // PROPERTY IMAGE
          // ─────────────────────────────
          Stack(
            children: [
              SizedBox(height: 160, width: double.infinity, child: Image.network('https://images.unsplash.com/photo-1600585154340-be6161a56a0c', fit: BoxFit.cover)),

              // Gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(.15), Colors.transparent, Colors.black.withOpacity(.35)]),
                  ),
                ),
              ),

              // Active badge
              Positioned(top: 18, left: 18, child: _StatusBadge(icon: Icons.circle, text: 'Active', backgroundColor: const Color(0xff246B63))),

              // Verified badge
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.95), borderRadius: BorderRadius.circular(30)),
                  child: const Row(
                    children: [
                      Icon(Icons.verified, size: 17, color: Color(0xff246B63)),
                      SizedBox(width: 6),
                      Text('Admin verified', style: TextStyle(color: Color(0xff246B63), fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ),

              // Favorite
              Positioned(right: 18, bottom: 58, child: _RoundButton(icon: Icons.favorite_border)),

              // Bookmark
              Positioned(right: 18, bottom: 12, child: _RoundButton(icon: Icons.bookmark_border)),
            ],
          ),

          // ─────────────────────────────
          // PROPERTY INFORMATION
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price
                const Text('₹20,00,000', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xff174E4A), letterSpacing: -0.8)),

                const SizedBox(height: 4),

                // Title
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Text('Testing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff263A39))),
                    const Spacer(),
                    Icon(Icons.location_on_outlined, size: 20, color: Colors.grey.shade600),
                    const SizedBox(width: 5),
                    Text('SG Highway', style: TextStyle(fontSize: 15, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                  ],
                ),

                const SizedBox(height: 18),

                // Features
                Row(
                  children: [_FeatureChip(icon: Icons.king_bed_outlined, text: '4 BHK'), const SizedBox(width: 8), _FeatureChip(icon: Icons.square_foot, text: '1500 sq ft'), const SizedBox(width: 8)],
                ),

                const SizedBox(height: 20),

                // Action row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border, size: 20),
                        label: const Text('Interested'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff246B63),
                          side: const BorderSide(color: Color(0xff246B63), width: 1.3),
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward, size: 19),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff193A3A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        children: [Icon(icon, size: 9, color: Colors.white), const SizedBox(width: 7), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13))],
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
