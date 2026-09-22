import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings'),
        actions: [
          IconButton(onPressed: state.loadBookings, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.loadBookings,
        child: state.bookings.isEmpty
            ? ListView(children: const [SizedBox(height: 220), Center(child: Text('No bookings yet. Explore a tour to get started.'))])
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.bookings.length,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.confirmation_number_outlined)),
                      title: Text(booking.tourName),
                      subtitle: Text('${booking.travelDate}\nKES ${booking.total.toStringAsFixed(0)}'),
                      isThreeLine: true,
                      trailing: Chip(label: Text(booking.status)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
