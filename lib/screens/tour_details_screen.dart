import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/tour.dart';
import '../state/app_state.dart';

class TourDetailsScreen extends StatefulWidget {
  const TourDetailsScreen({super.key, required this.tour});
  final Tour tour;

  @override
  State<TourDetailsScreen> createState() => _TourDetailsScreenState();
}

class _TourDetailsScreenState extends State<TourDetailsScreen> {
  DateTime date = DateTime.now().add(const Duration(days: 1));
  int travellers = 1;
  bool busy = false;

  Future<void> _selectDate() async {
    final selected = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: date);
    if (selected != null) setState(() => date = selected);
  }

  Future<void> _book() async {
    setState(() => busy = true);
    final success = await context.read<AppState>().createBooking(widget.tour.id, date, travellers);
    if (!mounted) return;
    setState(() => busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success ? 'Booking created successfully.' : 'Booking failed.')));
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tour = widget.tour;
    return Scaffold(
      appBar: AppBar(title: Text(tour.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 190,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), color: Theme.of(context).colorScheme.primaryContainer),
            child: const Center(child: Icon(Icons.photo_camera_back, size: 70)),
          ),
          const SizedBox(height: 20),
          Text(tour.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text(tour.location),
          const SizedBox(height: 12),
          Text(tour.description.isEmpty ? 'Experience an unforgettable Kenyan journey with Global Tours.' : tour.description),
          const SizedBox(height: 20),
          Text('KES ${tour.price.toStringAsFixed(0)} per traveller', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Travel date'), subtitle: Text(DateFormat.yMMMd().format(date)), trailing: const Icon(Icons.calendar_month), onTap: _selectDate),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Travellers'),
              Row(children: [
                IconButton(onPressed: travellers > 1 ? () => setState(() => travellers--) : null, icon: const Icon(Icons.remove_circle_outline)),
                Text('$travellers'),
                IconButton(onPressed: () => setState(() => travellers++), icon: const Icon(Icons.add_circle_outline)),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: busy ? null : _book, child: Text(busy ? 'Creating booking...' : 'Book now')),
        ],
      ),
    );
  }
}
