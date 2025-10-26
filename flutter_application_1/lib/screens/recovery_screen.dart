import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecoveryScreen extends StatefulWidget {
  const RecoveryScreen({super.key});
  @override
  State<RecoveryScreen> createState() => _RecoveryScreenState();
}

class _RecoveryScreenState extends State<RecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  final _auth = AuthService();
  String? _msg;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _msg = null; });
    try {
      final r = await _auth.resetRequest(_emailCtrl.text.trim());
      _msg = '$r';

      final args = {
        'email': _emailCtrl.text.trim(),
        'uid': (r['uid'] ?? '').toString(),
        'token': (r['token'] ?? '').toString(),
        'requestSent': r['sent'] ?? true,
        'gotoConfirm': true, // força abrir direto a aba de confirmação
      };

      if (!mounted) return;
      Navigator.of(context).pushNamed('/reset', arguments: args);
    } catch (e) {
      _msg = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3C6E91);
    const bg = Color(0xFFF2F8FB);
    const input = Color(0xFFD3E7EF);
    const accent = Color(0xFF9EC6D8);
    const text = Color(0xFF4E4E4E);
    const muted = Color(0xFF8A8A8A);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Verifique o e-mail', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text('Insira o e-mail', style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      style: const TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: input,
                        hintText: 'XXXXXX@email.com',
                        hintStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: primary, width: 1)),
                      ),
                      validator: (v) {
                        final value = v?.trim() ?? '';
                        if (value.isEmpty) return 'Informe o e-mail';
                        final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);
                        if (!ok) return 'E-mail inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: SizedBox()),
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                            ),
                            child: _loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.arrow_forward_rounded, size: 26),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_msg != null) Text(_msg!, style: const TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
