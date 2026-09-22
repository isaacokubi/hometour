class Tour {
  final String id, title, description, location, imageUrl;
  final double price;
  final int durationDays;
  final bool featured;
  const Tour({required this.id, required this.title, required this.description, required this.location, required this.imageUrl, required this.price, required this.durationDays, required this.featured});
  factory Tour.fromJson(Map<String, dynamic> j) => Tour(
    id: (j['_id'] ?? j['id'] ?? '').toString(),
    title: (j['title'] ?? j['name'] ?? 'Untitled tour').toString(),
    description: (j['description'] ?? '').toString(),
    location: (j['location'] ?? j['destination'] ?? 'Kenya').toString(),
    imageUrl: (j['image'] ?? j['imageUrl'] ?? j['coverImage'] ?? '').toString(),
    price: double.tryParse((j['price'] ?? j['amount'] ?? 0).toString()) ?? 0,
    durationDays: int.tryParse((j['durationDays'] ?? j['duration'] ?? 1).toString()) ?? 1,
    featured: j['featured'] == true,
  );
}
