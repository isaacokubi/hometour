import 'package:flutter/material.dart';

import '../core/domain.dart';
import '../services/global_tours_service.dart';

class RoleDashboardScreen extends StatefulWidget {
  const RoleDashboardScreen({
    super.key,
    required this.user,
    required this.onOpen,
  });

  final Map<String, dynamic> user;
  final void Function(String route) onOpen;

  @override
  State<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends State<RoleDashboardScreen> {
  final GlobalToursService service = GlobalToursService();
  DashboardStats? stats;
  Object? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final DashboardStats value =
          await service.stats('${widget.user['tenantId'] ?? ''}');
      if (mounted) {
        setState(() => stats = value);
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (stats == null && error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text('Dashboard error: $error'));
    }

    final DashboardStats current = stats!;
    final List<({String title, int value, IconData icon, String route})> cards =
        <({String title, int value, IconData icon, String route})>[
      (
        title: 'Tours',
        value: current.tours,
        icon: Icons.map,
        route: 'tours',
      ),
      (
        title: 'Bookings',
        value: current.bookings,
        icon: Icons.book_online,
        route: 'bookings',
      ),
      (
        title: 'Customers',
        value: current.customers,
        icon: Icons.people,
        route: 'users',
      ),
      (
        title: 'Destinations',
        value: current.destinations,
        icon: Icons.place,
        route: 'destinations',
      ),
      (
        title: 'Suppliers',
        value: current.suppliers,
        icon: Icons.business,
        route: 'suppliers',
      ),
      (
        title: 'Hotels',
        value: current.hotels,
        icon: Icons.hotel,
        route: 'hotels',
      ),
    ];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Text(
            'Welcome, ${widget.user['name'] ?? 'Global Tours user'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            roleLabel(roleFrom('${widget.user['role'] ?? ''}')),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 125,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (BuildContext context, int index) {
              final card = cards[index];
              return Card(
                child: InkWell(
                  onTap: () => widget.onOpen(card.route),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(card.icon),
                        const Spacer(),
                        Text(card.title),
                        Text(
                          '${card.value}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Card(
            child: ListTile(
              title: const Text('Pending bookings'),
              trailing: Text('${current.pending}'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Recorded booking value'),
              trailing: Text(
                '${widget.user['currency'] ?? 'KES'} '
                '${current.revenue.toStringAsFixed(2)}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
