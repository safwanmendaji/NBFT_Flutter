import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_images.dart';
import 'package:flutter_nobrokeragefortenants/controllers/visits_controller.dart';
 import 'package:flutter_nobrokeragefortenants/models/visits/visit_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/api_endpoints.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/visit_api.dart';
 import 'package:flutter_nobrokeragefortenants/services/network/error_manager.dart';

class VisitsScreen extends StatefulWidget {
  final bool isBroker;
  const VisitsScreen({super.key, required this.isBroker});

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  late final VisitsController controller;

  @override
  void initState() {
    super.initState();
    controller = VisitsController(
      repository: VisitApi(context),
      isBroker: widget.isBroker,
    )..addListener(_onControllerChanged);
    controller.loadVisits();
  }

  @override
  void dispose() {
    controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.isBroker ? 'My Visits' : 'My Visits',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          _tabs(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.loadVisits,
              color: AppColors.primary,
              child:
                controller.isLoading
                      ? const Center(child: CircularProgressIndicator())
                  : controller.visibleVisits.isEmpty
                      ? _emptyState()
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: controller.visibleVisits.length,
                        itemBuilder:
                    (_, index) =>
                      _visitCard(controller.visibleVisits[index]),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(VisitsController.tabs.length, (index) {
          final selected = controller.selectedTab == index;
          return GestureDetector(
            onTap: () => controller.selectTab(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xffe3e8e5)),
              ),
              child: Text(
                VisitsController.tabs[index],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 90),
        const Icon(
          Icons.event_available_outlined,
          size: 58,
          color: AppColors.secondary,
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            'No ${VisitsController.tabs[controller.selectedTab].toLowerCase()} visits found',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _visitCard(VisitModel visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0d000000), blurRadius: 7)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 86,
                  height: 86,
                  child:
                      visit.image == null
                          ? Image.asset(AppIcons.icProperty, fit: BoxFit.cover)
                          : CachedNetworkImage(
                            imageUrl: '${AppEndpoints.imgUrl}${visit.image}',
                            fit: BoxFit.cover,
                            errorWidget:
                                (_, __, ___) => Image.asset(
                                  AppIcons.icProperty,
                                  fit: BoxFit.cover,
                                ),
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      visit.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            '${visit.date}, ${visit.time}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _status(visit.status),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (visit.status == 'pending' || visit.status == 'confirmed')
            _visitActions(visit),
        ],
      ),
    );
  }

  Widget _visitActions(VisitModel visit) {
    final isWorking = controller.actionVisitId == visit.id;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (visit.status == 'pending')
            TextButton.icon(
              onPressed: isWorking ? null : () => _confirmVisit(visit),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: const Text('Confirm'),
            ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: isWorking ? null : () => _cancelVisit(visit),
            icon:
                isWorking
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Icon(Icons.close, size: 18),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmVisit(VisitModel visit) async {
    await _performVisitAction(
      successMessage: 'Visit confirmed',
      action: () => controller.confirmVisit(visit.id),
    );
  }

  Future<void> _cancelVisit(VisitModel visit) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Cancel visit?'),
            content: const Text(
              'This visit will be cancelled for both the customer and broker.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep visit'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Cancel visit'),
              ),
            ],
          ),
    );
    if (shouldCancel != true || !mounted) return;
    await _performVisitAction(
      successMessage: 'Visit cancelled',
      action: () => controller.cancelVisit(visit.id),
    );
  }

  Future<void> _performVisitAction({
    required String successMessage,
    required Future<bool> Function() action,
  }) async {
    final succeeded = await action();
    if (!mounted) return;
    if (succeeded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
      return;
    }

    final error = controller.takeError();
    if (error != null) {
      ErrorManager().showErrorDialogue(e: error, context: context);
    }
  }

  Widget _status(String status) {
    final color =
        status == 'completed'
            ? const Color(0xffe4f3e5)
            : status == 'cancelled'
            ? const Color(0xffffe5e5)
            : const Color(0xffeaf5e8);
    final text =
        status == 'completed'
            ? 'Completed'
            : status == 'cancelled'
            ? 'Cancelled'
            : status == 'confirmed'
            ? 'Confirmed'
            : 'Pending';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
