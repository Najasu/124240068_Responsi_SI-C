import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/wishlist_controller.dart';
import 'views/auth_page.dart';
import 'views/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('wishlist');

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loginData') ?? false;

  Get.put(WishlistController());

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.loggedIn});

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFFE63946);

    return GetMaterialApp(
      title: 'ShoppingHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: seed),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      home: loggedIn ? const HomePage() : const AuthPage(isRegister: false),
    );
  }
}
