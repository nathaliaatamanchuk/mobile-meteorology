import 'package:flutter/material.dart';
import '../services/station_service.dart';
import '../models/station.dart';
import '../widgets/app_shell.dart';

class StationsScreen extends StatefulWidget {
  const StationsScreen({super.key});
  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final _svc = StationService();
  bool _loading = true;
  String? _err;
  List<Station> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final list = await _svc.list();
      setState(() {
        _items = list;
      });
    } catch (e) {
      setState(() {
        _err = '$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF4E4E4E);
    return AppShell(
      appBar: AppBar(
        title: const Text('Stations'),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.pushNamed(context, '/stations/add');
          if (created is Station) {
            setState(() {
              _items = [created, ..._items];
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Estação criada: ${created.name}')),
              );
            }
          } else if (created == true) {
            _load();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_err != null)
              ? Center(child: Text(_err!))
              : (_items.isEmpty)
                  ? const Center(child: Text('No stations', style: TextStyle(color: text)))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final s = _items[i];
                        return ListTile(
                          title: Text(s.name, style: const TextStyle(color: text, fontWeight: FontWeight.w700)),
                          subtitle: Text('${s.latitude}, ${s.longitude}\nID: ${s.guid}', style: const TextStyle(color: text)),
                          isThreeLine: true,
                          trailing: s.isActive
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.cancel, color: Colors.red),
                        );
                      },
                    ),
    );
  }
}
