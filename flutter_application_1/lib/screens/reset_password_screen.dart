import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tab = ValueNotifier<int>(0); // 0=request, 1=confirm
  final _email = TextEditingController();
  final _uid = TextEditingController();
  final _token = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  final _auth = AuthService();
  String? _msg;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _email.text = (args['email'] ?? '').toString();
      final uid = (args['uid'] ?? '').toString();
      final token = (args['token'] ?? '').toString();
      final gotoConfirm = args['gotoConfirm'] == true;

      if (uid.isNotEmpty) _uid.text = uid;
      if (token.isNotEmpty) _token.text = token;

      if (gotoConfirm) _tab.value = 1; // entra direto na aba de confirmação
    }
  }

  Future<void> _request() async {
    setState(() { _loading = true; _msg = null; });
    try {
      final r = await _auth.resetRequest(_email.text.trim());
      setState(() { _msg = '$r'; });

      final uid = (r['uid'] ?? '').toString();
      final token = (r['token'] ?? '').toString();
      if (uid.isNotEmpty && token.isNotEmpty) {
        _uid.text = uid;
        _token.text = token;
        _tab.value = 1;
      }
    } catch (e) {
      setState(() { _msg = '$e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _confirm() async {
    setState(() { _loading = true; _msg = null; });
    try {
      final r = await _auth.resetConfirm(
        uid: _uid.text.trim(),
        token: _token.text.trim(),
        newPassword: _new1.text,
        newPasswordConfirm: _new2.text,
      );
      setState(() { _msg = '$r'; });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada. Faça login.')));
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } catch (e) {
      setState(() { _msg = '$e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Reset')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<int>(
          valueListenable: _tab,
          builder: (_, i, __) {
            if (i == 0) {
              return Column(
                children: [
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loading ? null : _request, child: _loading ? const CircularProgressIndicator() : const Text('Request')),
                  TextButton(onPressed: () => _tab.value = 1, child: const Text('I have uid and token')),
                ],
              );
            } else {
              return ListView(
                children: [
                  TextField(controller: _uid, decoration: const InputDecoration(labelText: 'UID')),
                  TextField(controller: _token, decoration: const InputDecoration(labelText: 'Token')),
                  TextField(controller: _new1, decoration: const InputDecoration(labelText: 'New password'), obscureText: true),
                  TextField(controller: _new2, decoration: const InputDecoration(labelText: 'Confirm new password'), obscureText: true),
                  const SizedBox(height: 12),
                  if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _loading ? null : _confirm, child: _loading ? const CircularProgressIndicator() : const Text('Confirm')),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
