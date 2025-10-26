import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../widgets/app_shell.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final _auth = AuthService();
  Future<AppUser>? _future;

  @override
  void initState() {
    super.initState();
    _future = _auth.me();
  }

  @override
  Widget build(BuildContext context) {
    const text = Color(0xFF4E4E4E);
    return AppShell(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<AppUser>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final u = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                ListTile(title: const Text('Username', style: TextStyle(color: text, fontWeight: FontWeight.w700)), subtitle: Text(u.username)),
                const Divider(),
                ListTile(title: const Text('Email', style: TextStyle(color: text, fontWeight: FontWeight.w700)), subtitle: Text(u.email)),
                const Divider(),
                ListTile(title: const Text('Nome', style: TextStyle(color: text, fontWeight: FontWeight.w700)), subtitle: Text('${u.firstName} ${u.lastName}')),
              ],
            ),
          );
        },
      ),
    );
  }
}
