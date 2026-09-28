import 'package:flutter/material.dart';
 import 'package:flutter_nobrokeragefortenants/core/constants/app_colors.dart';
 import 'package:flutter_nobrokeragefortenants/models/notifications/notification_model.dart';
 import 'package:flutter_nobrokeragefortenants/services/api/notification_api.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isBroker;

  const NotificationsScreen({super.key, required this.isBroker});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool isLoading = true;
  List<NotificationModel> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final result =
          widget.isBroker
              ? await NotificationApi.getBrokerNotifications(context: context)
              : await NotificationApi.getUserNotifications(context: context);
      if (mounted) {
        setState(() {
          notifications = result;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf9f6),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xfffaf9f6),
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.primary,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                ? _emptyState()
                : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder:
                      (_, index) => _notificationCard(notifications[index]),
                ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 130),
        Icon(
          Icons.notifications_none_rounded,
          size: 62,
          color: AppColors.secondary,
        ),
        SizedBox(height: 16),
        Center(
          child: Text(
            'No notifications yet',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _notificationCard(NotificationModel notification) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xffeaf5f1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe3e9e5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Icon(
              notification.isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (notification.message.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (notification.date.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    notification.date,
                    style: const TextStyle(
                      color: AppColors.gray500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!notification.isRead)
            Container(
              height: 9,
              width: 9,
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
