class UserRequirement {
  final String id;
  final String propertyPurpose;
  final String propertyType;
  final String floor;
  final String furnished;
  final String format;
  final String state;
  final String city;
  final String area;
  final String size;
  final dynamic priceRange;
  final String scheme;
  final dynamic pincode;
  final dynamic amount;

  const UserRequirement({
    required this.id,
    required this.propertyPurpose,
    required this.propertyType,
    required this.floor,
    required this.furnished,
    required this.format,
    required this.state,
    required this.city,
    required this.area,
    required this.size,
    required this.priceRange,
    required this.scheme,
    required this.pincode,
    required this.amount,
  });

  factory UserRequirement.fromJson(Map<String, dynamic> json) {
    final row =
        json['requirement'] is Map
            ? Map<String, dynamic>.from(json['requirement'])
            : json;
    return UserRequirement(
      id: (row['_id'] ?? row['id'] ?? '').toString(),
      propertyPurpose: (row['propertyPurpose'] ?? '').toString(),
      propertyType: (row['propertyType'] ?? '').toString(),
      floor: (row['floor'] ?? '').toString(),
      furnished: (row['furnished'] ?? '').toString(),
      format: (row['format'] ?? '').toString(),
      state: (row['state'] ?? '').toString(),
      city: (row['city'] ?? '').toString(),
      area: (row['area'] ?? '').toString(),
      size: (row['size'] ?? '').toString(),
      priceRange: row['priceRange'] ?? 0,
      scheme: (row['scheme'] ?? '').toString(),
      pincode: row['pincode'] ?? 0,
      amount: row['amount'] ?? 0,
    );
  }
}
