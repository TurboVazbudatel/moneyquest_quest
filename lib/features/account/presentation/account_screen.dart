import 'package:flutter/material.dart';
import '../../../data/services/profile_service.dart';
import '../../../data/services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _profile = ProfileService();
  final _auth = AuthService();

  String? _name;
  bool _guest = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _profile.getName();
    final guest = await _profile.isGuest();
    if (!mounted) return;
    setState(() {
      _name = name;
      _guest = guest;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    await _profile.setOnboarded(false); // чтобы при следующем запуске показать онбординг
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final title = _name?.isNotEmpty == true ? 'Привет, $_name' : 'Привет!';
    return Scaffold(
      appBar: AppBar(title: const Text('Аккаунт')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person_outline)),
              title: Text(title),
              subtitle: Text(_guest ? 'Статус: Гость' : 'Статус: Авторизован'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('О приложении'),
                  subtitle: Text('MoneyQuest — игровой подход к личным финансам'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Выйти'),
                  onTap: _signOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
