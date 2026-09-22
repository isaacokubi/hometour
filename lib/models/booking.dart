import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String status;
  final String tourName;
  final String travelDate;
  final double total;

  const Booking({
    required this.id,
    required this.status,
    required this.tourName,
    required this.travelDate,
    required this.total,
  });

  factory Booking.fromJson(Map<String, dynamic> j) {
    return Booking(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      status: (j['status'] ?? 'pending').toString(),
      tourName: (j['tourName'] ?? j['tourTitle'] ?? 'Tour booking').toString(),
      travelDate: _dateValue(j['travelDate'] ?? j['date']),
      total: _doubleValue(j['totalAmount'] ?? j['total'] ?? j['amount']),
    );
  }

  static String _dateValue(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DateTime) return value.toIso8601String();
    return value?.toString() ?? '';
  }

  static double _doubleValue(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
