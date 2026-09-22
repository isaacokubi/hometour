import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'tour_details_screen.dart';

class ToursScreen extends StatelessWidget {
  const ToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tours'),
        actions: [IconButton(onPressed: state.loadTours, icon: const Icon(Icons.refresh))],
      ),
      body: RefreshIndicator(
        onRefresh: state.loadTours,
        child: state.tours.isEmpty
            ? ListView(children: const [SizedBox(height: 220), Center(child: Text('No tours are currently available.'))])
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.tours.length,
                itemBuilder: (context, index) {
                  final tour = state.tours[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(tour.title),
                      subtitle: Text('${tour.location} • ${tour.durationDays} day(s) • KES ${tour.price.toStringAsFixed(0)}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TourDetailsScreen(tour: tour))),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
