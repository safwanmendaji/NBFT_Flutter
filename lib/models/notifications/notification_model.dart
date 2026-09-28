class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String date;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['subject'] ?? 'Notification').toString(),
      message:
          (json['message'] ?? json['body'] ?? json['description'] ?? '')
              .toString(),
      date: (json['createdAt'] ?? json['date'] ?? '').toString(),
      isRead: json['isRead'] == true || json['read'] == true,
    );
  }
}
