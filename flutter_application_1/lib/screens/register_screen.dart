import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  String? _msg;
  final _auth = AuthService();

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _first.dispose();
    _last.dispose();
    _pass.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _msg = null; });
    try {
      await _auth.register(
        username: _username.text.trim(),
        email: _email.text.trim(),
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        password: _pass.text,
        passwordConfirm: _pass2.text,
      );
      if (!mounted) return;
      setState(() { _msg = 'Conta criada. Faça login.'; });
    } catch (e) {
      setState(() { _msg = '$e'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3C6E91);
    const bg = Color(0xFFF2F8FB);
    const input = Color(0xFFD3E7EF);
    const text = Color(0xFF4E4E4E);
    const muted = Color(0xFF8A8A8A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              const Text('Crie sua conta', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _username,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'Username', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'E-mail', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _first,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'Nome', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _last,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'Sobrenome', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass,
                obscureText: true,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'Senha', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
                validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pass2,
                obscureText: true,
                decoration: InputDecoration(filled: true, fillColor: input, labelText: 'Confirmar senha', border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none)),
                validator: (v) => v != _pass.text ? 'Senhas diferentes' : null,
              ),
              const SizedBox(height: 16),
              if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.blue)),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading ? const CircularProgressIndicator() : const Text('Criar Conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
