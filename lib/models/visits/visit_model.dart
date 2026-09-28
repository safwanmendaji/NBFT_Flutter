class VisitModel {
  final String id;
  final String title;
  final String location;
  final String date;
  final String time;
  final String status;
  final String? image;

  const VisitModel({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.image,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    final property =
        json['property'] is Map
            ? Map<String, dynamic>.from(json['property'])
            : json['propertyId'] is Map
            ? Map<String, dynamic>.from(json['propertyId'])
            : json;
    final visitDate = json['visitDate'] ?? json['date'] ?? json['scheduledAt'];
    final parsedDate = DateTime.tryParse(visitDate?.toString() ?? '');
    final media = property['media'];
    final image =
        media is List && media.isNotEmpty && media.first is Map
            ? media.first['path']?.toString()
            : null;

    return VisitModel(
      id: (json['_id'] ?? json['id'] ?? property['_id'] ?? '').toString(),
      title:
          (property['title'] ?? property['name'] ?? 'Property visit')
              .toString(),
      location:
          (property['location'] ?? property['area'] ?? 'Location unavailable')
              .toString(),
      date:
          parsedDate == null
              ? (json['date'] ?? 'Date unavailable').toString()
              : _date(parsedDate),
      time:
          json['startTime'] == null
              ? parsedDate == null
                  ? (json['time'] ?? 'Time unavailable').toString()
                  : _time(parsedDate)
              : json['endTime'] == null
              ? json['startTime'].toString()
              : '${json['startTime']} - ${json['endTime']}',
      status: _normalizeStatus((json['status'] ?? 'pending').toString()),
      image: image,
    );
  }

  static String _normalizeStatus(String value) {
    final normalized = value.toLowerCase().replaceAll('_', ' ');
    if (normalized.contains('cancel')) return 'cancelled';
    if (normalized.contains('complete') || normalized.contains('done'))
      return 'completed';
    if (normalized.contains('confirm')) return 'confirmed';
    return 'pending';
  }

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')} ${_month(date.month)} ${date.year}';
  static String _time(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  static String _month(int month) =>
      const [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month];
}
