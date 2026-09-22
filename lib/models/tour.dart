class Tour {
  final String id;
  final String title;
  final String description;
  final String location;
  final String imageUrl;
  final double price;
  final int durationDays;
  final bool featured;

  const Tour({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.imageUrl,
    required this.price,
    required this.durationDays,
    required this.featured,
  });

  factory Tour.fromJson(Map<String, dynamic> j) => Tour(
        id: (j['id'] ?? j['_id'] ?? '').toString(),
        title: (j['title'] ?? j['name'] ?? 'Untitled tour').toString(),
        description: (j['description'] ?? '').toString(),
        location: (j['location'] ?? j['destination'] ?? 'Kenya').toString(),
        imageUrl: (j['imageUrl'] ?? j['image'] ?? j['coverImage'] ?? '').toString(),
        price: _doubleValue(j['price'] ?? j['amount']),
        durationDays: _intValue(j['durationDays'] ?? j['duration']),
        featured: j['featured'] == true,
      );

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _intValue(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }
}
