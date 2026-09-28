import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/local_strings.dart';
import 'package:flutter_nobrokeragefortenants/core/utils/preferences.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
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
              onChanged: (_) => setState(() {}),
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
                      : ListView.builder(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), itemCount: properties.length, itemBuilder: (context, index) => _propertyCard(properties[index])),
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
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? Colors.white : AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
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
    final imagePath = property.media?.isNotEmpty == true ? property.media!.first.path : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 7)]),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child:
                imagePath == null
                    ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
                    : CachedNetworkImage(imageUrl: '${AppEndpoints.imgUrl}$imagePath', fit: BoxFit.cover, errorWidget: (_, __, ___) => Image.asset(AppIcons.icProperty, fit: BoxFit.cover)),
          ),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(property.title ?? 'Untitled property', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5),
                Text(property.location ?? property.area ?? 'Location unavailable', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.gray500, fontSize: 13)),
                const SizedBox(height: 8),
                Text(property.price == null ? 'Price unavailable' : '₹${property.price}', style: const TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
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
