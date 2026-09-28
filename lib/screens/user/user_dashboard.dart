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
    _loadProperties();
    _loadSubscription();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    try {
      final response = await Propertyapis.getSharedProperties(
        context: context,
        userId: Prefs.getString(LocalStrings.userid),
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
        final purpose = cachedPurpose.isNotEmpty
          ? cachedPurpose
          : Prefs.getBool(LocalStrings.subscribedCommercial, false) == true
            ? 'Commercial'
            : Prefs.getBool(LocalStrings.subscribedResidential, false) == true
              ? 'Residential'
              : '';
      final isRefunded = false;
      if (mounted && (start != null || end != null || purpose.isNotEmpty)) {
        setState(() => _subscription = SubscriptionStatus(
          startDate: start,
          endDate: end,
          isRefunded: isRefunded,
          propertyPurpose: purpose,
        ));
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
                final searchableText =
                    [
                      property.title,
                      property.location,
                      property.area,
                      property.category,
                      property.format,
                    ].whereType<String>().join(' ').toLowerCase();
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

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
                    _propertyList(),
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
        Text(
          'Hello, $name',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 25,
            height: 1.15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Welcome to your private curation',
          style: TextStyle(color: AppColors.gray500, fontSize: 13),
        ),
      ],
    );
  }

  Widget _membershipCard() {
    final days = _daysRemaining;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xffffe9bd),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statusPill('Membership', _membershipStatus, AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: _statusPill('Plan', _planName, const Color(0xfff8f0e2)),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                ),
                child: const Text(
                  'Manage plan',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                days == null ? '--' : '${days.clamp(0, 9999)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Text('days remaining', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Text(
                _planExpiry == null
                    ? 'Plan dates unavailable'
                    : 'Valid till ${_formatDate(_planExpiry!)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          if (days != null && _subscription?.isActive == true) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 7,
                backgroundColor: Color(0xfff6f0e5),
                value:
                    _planStart != null && _planExpiry != null
                        ? (DateTime.now().difference(_planStart!).inSeconds /
                                _planExpiry!
                                    .difference(_planStart!)
                                    .inSeconds)
                            .clamp(0.0, 1.0)
                        : 0,
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
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color:
                color == AppColors.primary ? Colors.white : AppColors.primary,
            fontSize: 10,
          ),
          children: [
            TextSpan(text: '$title\n'),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xffeeeae3)),
            ),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: const Color(0xffeeeae3)),
          ),
          child: const Icon(
            Icons.tune_rounded,
            size: 21,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _suggestedHeading() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Text(
            'Admin suggested for you',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${visibleProperties.length} listings',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _propertyList() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (visibleProperties.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.home_work_outlined,
              size: 50,
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),
            Text(
              _searchController.text.isEmpty
                  ? 'No properties available yet'
                  : 'No properties match your search',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: visibleProperties.take(6).map(_propertyCard).toList(),
    );
  }

  Widget _propertyCard(Data property) {
    final imagePath =
        property.media?.isNotEmpty == true ? property.media!.first.path : null;
    final title = property.title ?? 'Untitled property';
    final location =
        property.location ?? property.area ?? 'Location unavailable';
    final price =
        property.price == null ? 'Price unavailable' : '₹${property.price}';
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserPropertyDetails(property: property))),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 8)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 180,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imagePath == null
                    ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
                    : CachedNetworkImage(
                      imageUrl: '${AppEndpoints.imgUrl}$imagePath',
                      fit: BoxFit.cover,
                      errorWidget:
                          (_, __, ___) => Image.asset(
                            AppIcons.icProperty,
                            fit: BoxFit.cover,
                          ),
                    ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: _imageTag(
                    property.status ?? 'Available',
                    AppColors.primary,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: _imageTag('Admin verified', Colors.white),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(property),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: .9),
                      child: Icon(
                        UserPropertyStorage.ids(
                              UserPropertyStorage.wishlistKey,
                            ).contains(property.sId)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 19,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 25,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.gray500,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _detailChip(
                      Icons.king_bed_outlined,
                      property.format ?? 'Details unavailable',
                    ),
                    _detailChip(
                      Icons.square_foot,
                      property.size ?? 'Area unavailable',
                    ),
                    _detailChip(Icons.remove_red_eye_outlined, 'See view'),
                  ],
                ),
                const SizedBox(height: 11),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed: () => _toggleInterested(property),
                    icon: Icon(
                      UserPropertyStorage.ids(
                            UserPropertyStorage.interestedKey,
                          ).contains(property.sId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 17,
                    ),
                    label: const Text(
                      'Mark as interested',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward, size: 17),
                    label: const Text(
                      'View details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1e3034),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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

  Widget _imageTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == Colors.white ? AppColors.primary : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xfff1f3f2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
