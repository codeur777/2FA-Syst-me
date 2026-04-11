import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';

class Verify2FAScreen extends StatefulWidget {
  final String email;
  const Verify2FAScreen({super.key, required this.email});

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  int _resendCooldown = 0;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _submit() async {
    if (_code.length < 6) {
      setState(() => _error = 'Entrez les 6 chiffres');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiClient.post('/auth/verify-2fa', {
        'email': widget.email,
        'code': _code,
      });
      final auth = context.read<AuthProvider>();
      await auth.saveTokens(data['accessToken'], data['refreshToken']);
      await auth.loadProfile();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        for (final c in _controllers) c.clear();
      });
      _focusNodes[0].requestFocus();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendCode() async {
    _startCooldown();
    try {
      await ApiClient.post('/auth/resend-otp', {'email': widget.email});
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendCooldown--);
      return _resendCooldown > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Vérification 2FA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('📧', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text('Code de vérification', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text('Code envoyé à ${widget.email}', style: TextStyle(color: cs.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                      child: Text(_error!, style: TextStyle(color: Colors.red.shade700), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // OTP inputs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) => Container(
                      width: 48,
                      height: 56,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextFormField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (v) {
                          if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                          if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                        },
                      ),
                    )),
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Vérifier', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _resendCooldown > 0 ? null : _resendCode,
                    child: Text(_resendCooldown > 0 ? 'Renvoyer (${_resendCooldown}s)' : 'Renvoyer le code'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
