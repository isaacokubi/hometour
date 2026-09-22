import 'package:flutter_test/flutter_test.dart';

import 'package:hometour/models/booking.dart';
import 'package:hometour/models/tour.dart';

void main() {
  test('Tour maps Global Tours API payload', () {
    final tour = Tour.fromJson({
      '_id': 'tour-1',
      'title': 'Maasai Mara Safari',
      'description': 'Three days in the Mara',
      'location': 'Maasai Mara',
      'price': 45000,
      'durationDays': 3,
      'featured': true,
    });

    expect(tour.id, 'tour-1');
    expect(tour.title, 'Maasai Mara Safari');
    expect(tour.price, 45000);
    expect(tour.durationDays, 3);
    expect(tour.featured, isTrue);
  });

  test('Booking maps populated tour and booking totals', () {
    final booking = Booking.fromJson({
      '_id': 'booking-1',
      'status': 'pending',
      'travelDate': '2026-10-18T00:00:00.000Z',
      'totalAmount': 90000,
      'tour': {'_id': 'tour-1', 'title': 'Maasai Mara Safari'},
    });

    expect(booking.id, 'booking-1');
    expect(booking.tourName, 'Maasai Mara Safari');
    expect(booking.total, 90000);
    expect(booking.status, 'pending');
  });
}
