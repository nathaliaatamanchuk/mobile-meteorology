import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final dynamic station;
  const LoginScreen({super.key, this.station});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  final _auth = AuthService();

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.login(_userCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goRecoveryOrRegister() {
    Navigator.of(context).pushNamed('/recovery');
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3C6E91);
    const bg = Color(0xFFF2F8FB);
    const input = Color(0xFFD3E7EF);
    const accent = Color(0xFF9EC6D8);
    const text = Color(0xFF4E4E4E);
    const muted = Color(0xFF8A8A8A);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: bg,
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(Icons.cloud_outlined, size: 32, color: primary),
                              SizedBox(width: 48, height: 48, child: CustomPaint(painter: _SignalPainter(color: primary.withOpacity(0.65)))),
                            ],
                          ),
                          const SizedBox(width: 8),
                          const Text('Login', style: TextStyle(color: text, fontSize: 26, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Text('User', style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _userCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o usuário/e-mail' : null,
                      ),
                      const SizedBox(height: 20),
                      const Text('Password', style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        style: const TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w600),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: input,
                          hintText: '************',
                          hintStyle: const TextStyle(color: muted, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscure = !_obscure),
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: muted),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: const BorderSide(color: primary, width: 1)),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          if (v.length < 6) return 'Mínimo de 6 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
                              onPressed: _goRecoveryOrRegister,
                              child: const Text('Esqueci minha senha\nou não tenho cadastro', textAlign: TextAlign.left, style: TextStyle(color: Color(0xFF8A8A8A), fontWeight: FontWeight.w700, fontSize: 14, height: 1.2)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9EC6D8), foregroundColor: Colors.white, shape: const CircleBorder(), elevation: 0, padding: EdgeInsets.zero),
                              child: _loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_rounded, size: 26, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  final Color color;
  const _SignalPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.8;
    final center = Offset(size.width * 0.28, size.height * 0.28);
    for (int i = 0; i < 3; i++) {
      final r = 8 + i * 4;
      final rect = Rect.fromCircle(center: center, radius: r.toDouble());
      canvas.drawArc(rect, -2.6, 1.2, false, p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
