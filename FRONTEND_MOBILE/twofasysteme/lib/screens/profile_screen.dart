import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../providers/auth_provider.dart';

const _faqItems = [
  ('Qu\'est-ce que la 2FA ?', 'La 2FA ajoute une couche de sécurité. Un code est envoyé à votre email à chaque connexion.'),
  ('Comment désactiver la 2FA ?', 'Dans l\'onglet Sécurité, utilisez le bouton pour désactiver la double authentification.'),
  ('Je ne reçois pas le code 2FA ?', 'Vérifiez vos spams. Le code expire après 10 minutes. Vous pouvez en demander un nouveau.'),
  ('Comment changer mon mot de passe ?', 'Dans l\'onglet Sécurité, entrez votre mot de passe actuel puis le nouveau (min. 8 caractères).'),
  ('Mes données sont-elles sécurisées ?', 'Oui. Mots de passe chiffrés avec BCrypt, tokens JWT avec expiration 24h.'),
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: Icon(auth.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: auth.toggleTheme,
            tooltip: 'Changer le thème',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline), text: 'Profil'),
            Tab(icon: Icon(Icons.security), text: 'Sécurité'),
            Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProfileTab(user: user),
          _SecurityTab(user: user),
          const _FaqTab(),
        ],
      ),
    );
  }
}

// ── Profil Tab ──
class _ProfileTab extends StatefulWidget {
  final dynamic user;
  const _ProfileTab({required this.user});

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  bool _loading = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.user.firstName);
    _lastNameCtrl = TextEditingController(text: widget.user.lastName);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() { _loading = true; _message = null; });
    try {
      await context.read<AuthProvider>().updateProfile({
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      });
      setState(() { _message = 'Profil mis à jour'; _isError = false; });
    } on ApiException catch (e) {
      setState(() { _message = e.message; _isError = true; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_message != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isError ? Colors.red.shade200 : Colors.green.shade200),
              ),
              child: Text(_message!, style: TextStyle(color: _isError ? Colors.red.shade700 : Colors.green.shade700)),
            ),
            const SizedBox(height: 16),
          ],

          Row(children: [
            Expanded(child: TextFormField(controller: _firstNameCtrl, decoration: const InputDecoration(labelText: 'Prénom'))),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(controller: _lastNameCtrl, decoration: const InputDecoration(labelText: 'Nom'))),
          ]),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: user.email,
            enabled: false,
            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone', prefixIcon: Icon(Icons.phone_outlined)),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _save,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Sauvegarder'),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Déconnecter')),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Se déconnecter', style: TextStyle(color: Colors.red, fontSize: 16)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Sécurité Tab ──
class _SecurityTab extends StatefulWidget {
  final dynamic user;
  const _SecurityTab({required this.user});

  @override
  State<_SecurityTab> createState() => _SecurityTabState();
}

class _SecurityTabState extends State<_SecurityTab> {
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _message;
  bool _isError = false;

  @override
  void dispose() {
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPassCtrl.text != _confirmCtrl.text) {
      setState(() { _message = 'Les mots de passe ne correspondent pas'; _isError = true; });
      return;
    }
    setState(() { _loading = true; _message = null; });
    try {
      await ApiClient.put('/user/change-password', {
        'currentPassword': _currentPassCtrl.text,
        'newPassword': _newPassCtrl.text,
      });
      _currentPassCtrl.clear();
      _newPassCtrl.clear();
      _confirmCtrl.clear();
      setState(() { _message = 'Mot de passe modifié avec succès'; _isError = false; });
    } on ApiException catch (e) {
      setState(() { _message = e.message; _isError = true; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 2FA toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Double authentification (2FA)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Code envoyé par email à chaque connexion', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: user.twoFactorEnabled ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          user.twoFactorEnabled ? '✓ Activée' : '✗ Désactivée',
                          style: TextStyle(
                            color: user.twoFactorEnabled ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  )),
                  Switch(
                    value: user.twoFactorEnabled,
                    onChanged: (v) => auth.toggleTwoFactor(v),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          Text('Changer le mot de passe', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          if (_message != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isError ? Colors.red.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _isError ? Colors.red.shade200 : Colors.green.shade200),
              ),
              child: Text(_message!, style: TextStyle(color: _isError ? Colors.red.shade700 : Colors.green.shade700)),
            ),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _currentPassCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Mot de passe actuel',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nouveau mot de passe', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirmer le mot de passe', prefixIcon: Icon(Icons.lock_outline)),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _changePassword,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Changer le mot de passe'),
          ),
        ],
      ),
    );
  }
}

// ── FAQ Tab ──
class _FaqTab extends StatefulWidget {
  const _FaqTab();

  @override
  State<_FaqTab> createState() => _FaqTabState();
}

class _FaqTabState extends State<_FaqTab> {
  int? _open;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _faqItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final (q, a) = _faqItems[i];
        return Card(
          child: ExpansionTile(
            title: Text(q, style: const TextStyle(fontWeight: FontWeight.w500)),
            initiallyExpanded: _open == i,
            onExpansionChanged: (v) => setState(() => _open = v ? i : null),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(a, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), height: 1.5)),
              ),
            ],
          ),
        );
      },
    );
  }
}
