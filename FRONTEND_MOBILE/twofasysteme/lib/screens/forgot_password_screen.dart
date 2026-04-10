import 'package:flutter/material.dart';
import '../core/api_client.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 1;
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _success;

  @override
  void dispose() {
    for (final c in [_emailCtrl, _codeCtrl, _newPassCtrl, _confirmCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Email requis');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient.post('/auth/forgot-password', {'email': _emailCtrl.text.trim()});
      setState(() {
        _step = 2;
        _success = 'Si cet email existe, un code a été envoyé.';
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_newPassCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Les mots de passe ne correspondent pas');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient.post('/auth/reset-password', {
        'email': _emailCtrl.text.trim(),
        'code': _codeCtrl.text.trim(),
        'newPassword': _newPassCtrl.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe réinitialisé avec succès !'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('🔑', style: TextStyle(fontSize: 56), textAlign: TextAlign.center),
                  const SizedBox(height: 24),

                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
                      child: Text(_error!, style: TextStyle(color: Colors.red.shade700)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_success != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green.shade200)),
                      child: Text(_success!, style: TextStyle(color: Colors.green.shade700)),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_step == 1) ...[
                    Text('Entrez votre email pour recevoir un code.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _sendCode,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Envoyer le code'),
                    ),
                  ] else ...[
                    Text('Entrez le code reçu et votre nouveau mot de passe.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(labelText: 'Code de vérification', prefixIcon: Icon(Icons.pin_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _newPassCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Nouveau mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock_outline)),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _resetPassword,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Réinitialiser'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
