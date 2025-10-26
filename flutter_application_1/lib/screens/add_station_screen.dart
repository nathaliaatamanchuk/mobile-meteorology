import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/station_service.dart';
import '../models/station.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});
  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  bool _active = true;
  bool _loading = false;
  String? _msg;
  final _svc = StationService();

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _msg = null; });
    try {
      final Station s = await _svc.create(
        name: _name.text.trim(),
        description: _description.text.trim(),
        latitude: double.parse(_lat.text),
        longitude: double.parse(_lng.text),
        isActive: _active,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Estação criada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${s.name}'),
                const SizedBox(height: 6),
                Text('ID (guid): ${s.guid}'),
                const SizedBox(height: 12),
                const Text('Use o ID da estação criada para relacionar com seu firmware.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: s.guid));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado')));
                },
                child: const Text('Copiar ID'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      Navigator.pop(context, s); // ✅ devolve a estação criada pra lista
    } catch (e) {
      setState(() { _msg = '$e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const input = Color(0xFFD3E7EF);
    return Scaffold(
      appBar: AppBar(title: const Text('Add Station')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: InputDecoration(
                  filled: true, fillColor: input, labelText: 'Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: InputDecoration(
                  filled: true, fillColor: input, labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lat,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true, fillColor: input, labelText: 'Latitude',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lng,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  filled: true, fillColor: input, labelText: 'Longitude',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (v) => setState(() => _active = v),
              ),
              if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const CircularProgressIndicator() : const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
