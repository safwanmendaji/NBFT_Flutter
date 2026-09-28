class SubscriptionStatus {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isRefunded;
  final String propertyPurpose;

  const SubscriptionStatus({
    this.startDate,
    this.endDate,
    required this.isRefunded,
    this.propertyPurpose = '',
  });

  bool get isActive {
    final now = DateTime.now();
    return startDate != null &&
        endDate != null &&
        !startDate!.isAfter(now) &&
        endDate!.isAfter(now) &&
        !isRefunded;
  }

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    final payload =
        json['subscription'] is Map
            ? Map<String, dynamic>.from(json['subscription'])
            : json;
    return SubscriptionStatus(
      startDate: DateTime.tryParse((payload['startDate'] ?? '').toString()),
      endDate: DateTime.tryParse((payload['endDate'] ?? '').toString()),
        isRefunded: payload['isRefunded'] == true,
        propertyPurpose:
          payload['customerPropertyRequirementId'] is Map
            ? (payload['customerPropertyRequirementId']['propertyPurpose'] ?? '').toString()
            : (payload['propertyPurpose'] ?? '').toString(),
    );
  }
}
