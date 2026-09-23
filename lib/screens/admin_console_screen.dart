import 'package:flutter/material.dart';

import '../core/domain.dart';
import '../services/global_tours_service.dart';

class AdminConsoleScreen extends StatefulWidget {
  const AdminConsoleScreen({
    super.key,
    required this.user,
    required this.collection,
    required this.title,
  });

  final Map<String, dynamic> user;
  final String collection;
  final String title;

  @override
  State<AdminConsoleScreen> createState() => _AdminConsoleScreenState();
}

class _AdminConsoleScreenState extends State<AdminConsoleScreen> {
  final GlobalToursService service = GlobalToursService();
  List<CatalogRecord> rows = <CatalogRecord>[];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      rows = await service.list(
        widget.collection,
        '${widget.user['tenantId'] ?? ''}',
      );
      error = null;
    } catch (e) {
      error = '$e';
    }
    if (mounted) {
      setState(() => loading = false);
    }
  }

  Future<void> _add() async {
    final TextEditingController name = TextEditingController();
    final TextEditingController desc = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Create ${widget.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name / title'),
              ),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok == true && name.text.trim().isNotEmpty) {
      await service.create(
        widget.collection,
        '${widget.user['tenantId'] ?? ''}',
        <String, dynamic>{
          'name': name.text.trim(),
          'description': desc.text.trim(),
          'status': 'active',
        },
      );
      name.dispose();
      desc.dispose();
      await _load();
    } else {
      name.dispose();
      desc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(child: Text(error!));
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: rows.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (BuildContext context, int index) {
            final CatalogRecord record = rows[index];
            return Card(
              child: ListTile(
                title: Text(record.name),
                subtitle: Text(
                  record.description.isEmpty
                      ? record.status
                      : record.description,
                ),
                trailing: Text(
                  record.price > 0
                      ? '${widget.user['currency'] ?? 'KES'} '
                          '${record.price.toStringAsFixed(0)}'
                      : record.status,
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            onPressed: _add,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: body,
    );
  }
}
