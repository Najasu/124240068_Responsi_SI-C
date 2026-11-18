import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/wishlist_controller.dart';
import '../utils/helpers.dart';
import 'home_page.dart';

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
  bool hidePass = true;

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

    await Get.find<WishlistController>().load();
    Get.offAll(() => const HomePage());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRegister = widget.isRegister;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isRegister
          ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.primaryContainer, cs.surface],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: cs.primary,
                        child: Icon(
                          Icons.shopping_bag_rounded,
                          size: 40,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
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
                    const SizedBox(height: 28),
                    Card(
                      elevation: 0,
                      color: cs.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: userC,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: passC,
                              obscureText: hidePass,
                              textInputAction:
                                  isRegister ? TextInputAction.next : TextInputAction.done,
                              onSubmitted: (_) {
                                if (!isRegister) submit();
                              },
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(hidePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                  onPressed: () =>
                                      setState(() => hidePass = !hidePass),
                                ),
                              ),
                            ),
                            if (isRegister) ...[
                              const SizedBox(height: 16),
                              TextField(
                                controller: confirmC,
                                obscureText: hidePass,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => submit(),
                                decoration: const InputDecoration(
                                  labelText: 'Konfirmasi Password',
                                  prefixIcon: Icon(Icons.lock_reset_outlined),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: submit,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(isRegister ? 'Register' : 'Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
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
      ),
    );
  }
}
