import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'tour_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final featured = state.tours.where((tour) => tour.featured).take(6).toList();
    final items = featured.isNotEmpty ? featured : state.tours.take(6).toList();
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('Global Tours'),
          actions: [IconButton(onPressed: state.loadTours, icon: const Icon(Icons.refresh))],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Discover Kenya', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Safari, coast, culture and tailor-made experiences in one travel app.'),
                const SizedBox(height: 20),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(colors: [Color(0xFF14532D), Color(0xFF22C55E)]),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(22),
                    child: Align(alignment: Alignment.bottomLeft, child: Text('Your next adventure starts here.', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Featured tours', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final tour = items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(radius: 30, child: Icon(Icons.landscape)),
                    title: Text(tour.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text('${tour.location} • ${tour.durationDays} day(s)\nKES ${tour.price.toStringAsFixed(0)}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TourDetailsScreen(tour: tour))),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}
