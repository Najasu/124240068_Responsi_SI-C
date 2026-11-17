import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/favorite_controller.dart';
import 'main_page.dart';
import '../utils/helpers.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.isRegister});

  final bool isRegister;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final userC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  final users = Hive.box('users');

  @override
  void dispose() {
    userC.dispose();
    passC.dispose();
    confirmC.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final user = userC.text.trim();
    final pass = passC.text;

    if (user.isEmpty || pass.isEmpty) {
      showSnack('Oops', 'Username dan password wajib diisi');
      return;
    }
    if (widget.isRegister) {
      await register(user, pass);
    } else {
      await login(user, pass);
    }
  }

  Future<void> register(String user, String pass) async {
    if (pass != confirmC.text) {
      showSnack('Oops', 'Konfirmasi password tidak sama');
      return;
    }
    if (users.containsKey(user)) {
      showSnack('Oops', 'Username sudah terdaftar');
      return;
    }
    await users.put(user, pass);
    Get.back(); 
    showSnack('Berhasil', 'Akun dibuat, silakan login');
  }

  Future<void> login(String user, String pass) async {
    if (users.get(user) != pass) {
      showSnack('Gagal', 'Username atau password salah');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', true);
    await prefs.setString('username', user);

    await Get.find<FavoriteController>().load();
    Get.offAll(() => const MainPage());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRegister = widget.isRegister;

    return Scaffold(
      appBar: isRegister ? AppBar() : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.shopping_basket_sharp, size: 72, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    isRegister ? 'Buat Akun' : 'ShoppingHub',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRegister
                        ? 'Daftar untuk mulai belanja'
                        : 'Belanja Puas Harga Pas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: userC,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (isRegister) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmC,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Konfirmasi Password',
                        prefixIcon: Icon(Icons.lock_reset_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(isRegister ? 'Register' : 'Login'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => isRegister
                        ? Get.back()
                        : Get.to(() => const AuthPage(isRegister: true)),
                    child: Text(isRegister
                        ? 'Sudah punya akun? Login'
                        : 'Belum punya akun? Register'),
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
