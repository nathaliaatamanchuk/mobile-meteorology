import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AppShell extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;

  const AppShell({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF9EC6D8);
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFF2F8FB),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Usuário',
                icon: const Icon(Icons.person_outline, color: Color(0xFF3C6E91)),
                onPressed: () => Navigator.of(context).pushNamed('/user'),
              ),
              const Spacer(),
              Ink(
                decoration: const ShapeDecoration(
                  color: accent,
                  shape: CircleBorder(),
                ),
                child: IconButton(
                  tooltip: 'Estações',
                  icon: const Icon(Icons.sensors, color: Colors.white),
                  onPressed: () => Navigator.of(context).pushNamed('/stations'),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout, color: Color(0xFF3C6E91)),
                onPressed: () async {
                  await AuthService().logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
