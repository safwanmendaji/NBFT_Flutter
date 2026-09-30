import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/models/properties/properties_model.dart';
import 'package:flutter_nobrokeragefortenants/services/api/property_api.dart';
import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
import 'package:flutter_nobrokeragefortenants/widgets/user_top_header.dart';

class UserPropertyDetails extends StatefulWidget {
  final Data property;

  const   UserPropertyDetails({super.key, required this.property});

  @override
  State<UserPropertyDetails> createState() => _UserPropertyDetailsState();
}

class _UserPropertyDetailsState extends State<UserPropertyDetails> {
  int imageIndex = 0;
  bool interested = false;
  bool interestLoading = false;

  Data get property => widget.property;

  Future<void> _setInterest() async {
    final propertyId = property.sId;
    if (propertyId == null || interestLoading) return;
    setState(() => interestLoading = true);
    try {
      await Propertyapis.markInterest(context: context, propertyId: propertyId, status: interested ? 'Not Interested' : 'Interested');
      if (!mounted) return;
      setState(() => interested = !interested);
      Fluttertoast.showToast(msg: interested ? 'Added to interested properties' : 'Removed from interested properties');
    } catch (error) {
      Fluttertoast.showToast(msg: 'Could not update interest');
      debugPrint('Interest update failed: $error');
    } finally {
      if (mounted) setState(() => interestLoading = false);
    }
  }

  void _contactBroker() {
    final broker = property.postedBy;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Broker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(broker?.fullName?.isNotEmpty == true ? broker!.fullName! : 'Property advisor'),
                  if (broker?.mobileNo?.isNotEmpty == true) ...[
                    const SizedBox(height: 14),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                      title: Text(broker!.mobileNo!),
                      subtitle: const Text('Broker phone number'),
                      onTap: () => Fluttertoast.showToast(msg: broker.mobileNo!),
                    ),
                  ],
                  if (broker?.email?.isNotEmpty == true)
                    ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.email_outlined, color: AppColors.primary), title: Text(broker!.email!), subtitle: const Text('Broker email')),
                ],
              ),
            ),
          ),
    );
  }

  String _price() => property.price == null ? 'Price on request' : '₹${property.price} /mo';

  @override
  Widget build(BuildContext context) {
    final media = property.media ?? [];
    final location = property.location ?? property.area ?? 'Location unavailable';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          //const UserTopHeader(),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 285,
                  centerTitle: true,
                  //title: Text("HELLOS"),
                  backgroundColor: AppColors.blackColor,
                  foregroundColor: Colors.white,
                  leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                  actions: [
                    IconButton(onPressed: _contactBroker, icon: const Icon(Icons.share_outlined)),
                    IconButton(onPressed: _setInterest, icon: Icon(interested ? Icons.favorite : Icons.favorite_border)),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (media.isEmpty)
                          Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
                        else
                          PageView.builder(
                            itemCount: media.length,
                            onPageChanged: (index) => setState(() => imageIndex = index),
                            itemBuilder:
                                (_, index) => CachedNetworkImage(
                                  imageUrl: '${AppEndpoints.imgUrl}${media[index].path}',
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Image.asset(AppIcons.icProperty, fit: BoxFit.cover),
                                ),
                          ),
                        Positioned(right: 14, bottom: 14, child: _badge('${media.isEmpty ? 1 : imageIndex + 1}/${media.isEmpty ? 1 : media.length}')),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.title ?? 'Property', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 17, color: AppColors.gray500),
                            const SizedBox(width: 4),
                            Expanded(child: Text(location, style: const TextStyle(color: AppColors.gray500, fontSize: 14))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_price(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const SizedBox(height: 18),
                        _facts(),
                        const SizedBox(height: 22),
                        const Text('About Property', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 8),
                        Text(
                          property.description?.isNotEmpty == true ? property.description! : 'Property details are available from the broker.',
                          style: const TextStyle(height: 1.45, color: AppColors.gray500),
                        ),
                        const SizedBox(height: 22),
                        const Text('Property Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        const SizedBox(height: 12),
                        _informationGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _contactBroker,
                  icon: const Icon(Icons.phone_outlined),
                  label: const Text('Contact Broker'),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, minimumSize: const Size.fromHeight(52)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _setInterest,
                  icon: Icon(interested ? Icons.favorite : Icons.favorite_border),
                  label: Text(interested ? 'Interested' : 'I am Interested'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _facts() => Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: const BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: Color(0xffedf0ed)))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _fact(Icons.king_bed_outlined, property.format ?? '—'),
        _fact(Icons.bathtub_outlined, property.furnished ?? '—'),
        _fact(Icons.square_foot, '${property.size ?? '—'} ${property.sizeType ?? ''}'),
      ],
    ),
  );

  Widget _fact(IconData icon, String value) =>
      Column(children: [Icon(icon, size: 21, color: AppColors.primary), const SizedBox(height: 5), Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))]);
  Widget _informationGrid() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xfffafcfa), border: Border.all(color: const Color(0xffe4e9e5)), borderRadius: BorderRadius.circular(12)),
    child: Column(
      children: [
        _infoRow('Purpose', property.type),
        _infoRow('Category', property.category),
        _infoRow('Format', property.format),
        _infoRow('Size', property.size == null ? null : '${property.size} ${property.sizeType ?? ''}'),
        _infoRow('Furnished', property.furnished),
        _infoRow('Floor', property.floor),
        _infoRow('Area', property.area),
        _infoRow('State', property.state),
        _infoRow('City', property.city),
        _infoRow('Pincode', property.pincode),
        _infoRow('Status', property.status),
      ],
    ),
  );

  Widget _infoRow(String label, String? value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 92, child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gray500))),
        Expanded(child: Text(value?.isNotEmpty == true ? value! : '—', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary))),
      ],
    ),
  );
  Widget _badge(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
  );
}
