class Booking {
  final String id, status, tourName, travelDate;
  final double total;
  const Booking({required this.id, required this.status, required this.tourName, required this.travelDate, required this.total});
  factory Booking.fromJson(Map<String, dynamic> j) {
    final tour = j['tour'] is Map ? j['tour'] as Map : {};
    return Booking(
      id: (j['_id'] ?? j['id'] ?? '').toString(),
      status: (j['status'] ?? 'pending').toString(),
      tourName: (tour['title'] ?? tour['name'] ?? j['tourName'] ?? 'Tour booking').toString(),
      travelDate: (j['travelDate'] ?? j['date'] ?? '').toString(),
      total: double.tryParse((j['totalAmount'] ?? j['total'] ?? j['amount'] ?? 0).toString()) ?? 0,
    );
  }
}
