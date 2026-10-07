import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/dialogs/dialogue.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/screens/user/schedule_screen.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/services/user_property_storage.dart';

class UserInterestedScreen extends StatefulWidget {
  const UserInterestedScreen({super.key});

  @override
  State<UserInterestedScreen> createState() => _UserInterestedScreenState();
}

class _UserInterestedScreenState extends State<UserInterestedScreen> {
  int selectedTab = 0;
  final searchController = TextEditingController();
  List<Data> properties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _removeFromInterested(Data property) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Remove from Interested?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            content: Text('“${property.title ?? 'This property'}” will be removed from your interested list.', style: const TextStyle(fontSize: 13, color: AppColors.gray500)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: AppColors.gray500))),
              TextButton(onPressed: () async{
               try {
                 await _removeInterested(property);
                 await _loadProperties();
                 displayToast(message: "Property remove successfully", context: context);
               } catch (e) {
                 print(e);
               }finally{
                 Navigator.pop(ctx, false);
               }
              }, child: const Text('Remove', style: TextStyle(color: Color(0xFFD9534F), fontWeight: FontWeight.w700))),
            ],
          ),
    );

    if (confirmed != true) return;

    // if (property.sId != null) {
    //   final ids = UserPropertyStorage.ids(UserPropertyStorage.interestedKey);
    //   ids.remove(property.sId);
    //   await UserPropertyStorage.save(
    //     UserPropertyStorage.interestedKey,
    //     ids.toList(),
    //   );
    // }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from interested'), behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2)));
    }
  }

  void _scheduleVisit(Data property) {
    print('=======> ${property.toJson()}');
    Navigator.push(context, MaterialPageRoute(builder: (context) => PropertyVisitBookingScreen(property: property)));
  }

  Future<void> _loadProperties() async {
    try {
      final response = await Propertyapis.getAllProperties(isShowProgress: false, context: context, id: Prefs.getString(LocalStrings.userid), params: {});
      if (mounted) {
        setState(() {
          properties = response.data ?? [];

          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<Data> get filteredProperties {
    final savedIds = UserPropertyStorage.ids(UserPropertyStorage.wishlistKey);
    final interestedIds = UserPropertyStorage.ids(UserPropertyStorage.interestedKey);
    final selectedIds = selectedTab == 0 ? savedIds : interestedIds;
    final query = searchController.text.trim().toLowerCase();

    return properties.where((property) {
      final isInSelectedList = property.sId != null && selectedIds.contains(property.sId);
      final searchableText = [property.title, property.location, property.area, property.category, property.format].whereType<String>().join(' ').toLowerCase();
      return isInSelectedList && (query.isEmpty || searchableText.contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Interested';
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 23, fontWeight: FontWeight.w700))),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (_) => setState(() {

              }),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: AppColors.gray500),
                hintText: 'Search $title properties',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xffeeeae3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: Color(0xffeeeae3))),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProperties,
              color: AppColors.primary,
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : properties.isEmpty
                      ? _emptyState(title)
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: properties.length,
                        itemBuilder: (context, index) => _propertyCard(properties[index]),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xffe8eeeb), borderRadius: BorderRadius.circular(11)),
      child: Row(children: [_tabButton('Saved as Wishlist', 0, Icons.bookmark_border), _tabButton('Interested', 1, Icons.favorite_border)]),
    );
  }

  Widget _tabButton(String label, int index, IconData icon) {
    final selected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap:
            () => setState(() {
              selectedTab = index;
              searchController.clear();
            }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: selected ? Colors.white : AppColors.primary),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: selected ? Colors.white : AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(String title) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 75),
        Icon(selectedTab == 0 ? Icons.bookmark_border : Icons.favorite_border, size: 58, color: AppColors.secondary),
        const SizedBox(height: 14),
        Center(
          child: Text(
            searchController.text.isEmpty ? 'No properties saved as $title yet' : 'No $title properties match your search',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary, fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _propertyCard(Data property) {
    final imagePath =
    property.media?.isNotEmpty == true
        ? property.media!.first.path
        : null;

    final isImage =
        property.media?.isNotEmpty == true &&
            property.media!.first.type == 'image';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppColors.white)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------------
          // IMAGE
          // ----------------------------------------------------------
          SizedBox(
            height: 140,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Property Image
                imagePath == null || !isImage
                    ? Image.asset(
                  AppIcons.icProperty,
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  imageUrl: '${AppEndpoints.imgUrl}$imagePath',
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Image.asset(
                    AppIcons.icProperty,
                    fit: BoxFit.cover,
                  ),
                ),

                // Dark gradient at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 90,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.65),
                        ],
                      ),
                    ),
                  ),
                ),

                // ----------------------------------------------------
                // TOP LEFT - PROPERTY TYPE
                // ----------------------------------------------------
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.home_work_outlined,
                          size: 15,
                          color: AppColors.blackColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Property',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ----------------------------------------------------
                // TOP RIGHT - INTERESTED
                // ----------------------------------------------------
                Positioned(
                  top: 10,
                  right: 10,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _removeFromInterested(property),
                      child:  const Padding(
                        padding: const EdgeInsets.all(9),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // ----------------------------------------------------
                // PRICE ON IMAGE
                // ----------------------------------------------------
                Positioned(
                  left: 14,
                  bottom: 12,
                  child: Text(
                    property.price == null
                        ? 'Price unavailable'
                        : '₹${property.price}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          color: Colors.black45,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ----------------------------------------------------------
          // DETAILS
          // ----------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  property.title ?? 'Untitled property',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location ??
                            property.area ??
                            'Location unavailable',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ----------------------------------------------------
                // PROPERTY INFO CHIPS
                // ----------------------------------------------------
                Row(
                  children: [
                    _propertyInfoChip(
                      icon: Icons.home_outlined,
                      label: 'Residential',
                    ),
                    const SizedBox(width: 8),
                    _propertyInfoChip(
                      icon: Icons.verified_outlined,
                      label: 'Verified',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ----------------------------------------------------
                // ACTION BUTTONS
                // ----------------------------------------------------
                Row(
                  children: [
                    // Remove
                    // Expanded(
                    //   child: SizedBox(
                    //     height: 48,
                    //     child: OutlinedButton.icon(
                    //       onPressed: () =>
                    //           _removeFromInterested(property),
                    //       icon: const Icon(
                    //         Icons.favorite_border_rounded,
                    //         size: 19,
                    //       ),
                    //       label: const Text(
                    //         'Remove',
                    //         maxLines: 1,
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //       style: OutlinedButton.styleFrom(
                    //         foregroundColor: colorScheme.error,
                    //         side: BorderSide(
                    //           color: colorScheme.error.withOpacity(0.6),
                    //         ),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(14),
                    //         ),
                    //         textStyle: theme.textTheme.labelLarge?.copyWith(
                    //           fontWeight: FontWeight.w700,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    //
                    // const SizedBox(width: 10),

                    // Schedule
                    Expanded(

                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () => _scheduleVisit(property),
                          icon: const Icon(
                            Icons.calendar_month_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Schedule Visit',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
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
    );
  }

  Widget _propertyInfoChip({
    required IconData icon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.white,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  // Widget _propertyCard(Data property) {
  //
  //   final imagePath = property.media?.isNotEmpty == true ? property.media!.first.path : null;
  //   final isImage = property.media?.isNotEmpty == true && property.media!.first.type == 'image';
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 14),
  //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 7)]),
  //     clipBehavior: Clip.antiAlias,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // ----------------- Image -----------------
  //         SizedBox(
  //           height: 150,
  //           width: double.infinity,
  //           child:
  //               imagePath == null || !isImage
  //                   ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
  //                   : CachedNetworkImage(
  //                     imageUrl: '${AppEndpoints.imgUrl}$imagePath',
  //                     fit: BoxFit.cover,
  //                     placeholder: (_, __) => Container(color: const Color(0xFFEDF0F1)),
  //                     errorWidget: (_, __, ___) => Image.asset(AppIcons.icProperty, fit: BoxFit.cover),
  //                   ),
  //         ),
  //
  //         // ----------------- Details -----------------
  //         Padding(
  //           padding: const EdgeInsets.all(13),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   Expanded(
  //                     child: Text(
  //                       property.title ?? 'Untitled property',
  //                       maxLines: 1,
  //                       overflow: TextOverflow.ellipsis,
  //                       style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //               Text(
  //                 property.location ?? property.area ?? 'Location unavailable',
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //                 style: const TextStyle(color: AppColors.gray500, fontSize: 13),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 property.price == null ? 'Price unavailable' : '₹${property.price}',
  //                 style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700),
  //               ),
  //               const SizedBox(height: 14),
  //
  //               // ----------------- Action Buttons -----------------
  //               Row(
  //                 children: [
  //                   // Remove from Interest
  //                   Expanded(
  //                     child: SizedBox(
  //                       height: 42,
  //                       child: OutlinedButton.icon(
  //                         onPressed: () => _removeFromInterested(property),
  //                         icon: const Icon(Icons.delete_outline_rounded, size: 17),
  //                         label: const Text('Remove from Interest', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
  //                         style: OutlinedButton.styleFrom(
  //                           foregroundColor: const Color(0xFFD9534F),
  //                           side: const BorderSide(color: Color(0xFFD9534F), width: 1.2),
  //                           padding: const EdgeInsets.symmetric(horizontal: 8),
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 10),
  //
  //                   // Schedule Visit
  //                   Expanded(
  //                     child: SizedBox(
  //                       height: 42,
  //                       child: ElevatedButton.icon(
  //                         onPressed: () => _scheduleVisit(property),
  //                         icon: const Icon(Icons.event_available_rounded, size: 17),
  //                         label: const Text('Schedule Visit', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
  //                         style: ElevatedButton.styleFrom(
  //                           backgroundColor: AppColors.primary,
  //                           foregroundColor: Colors.white,
  //                           elevation: 0,
  //                           padding: const EdgeInsets.symmetric(horizontal: 8),
  //                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future<void> _removeInterested(Data property) async {
    await Propertyapis.toggleInterest(context: context, propertyId: property.sId?.toString() ?? "", interested: property.status == "Interested" ? "Not Interested" : "Interested");

  }
}

class UserVisitScreen extends StatelessWidget {
  const UserVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _UserEmptyScreen(title: 'Visit', icon: Icons.event_available_outlined, message: 'Your scheduled property visits will appear here.');
  }
}

class _UserEmptyScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const _UserEmptyScreen({required this.title, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gray500, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
