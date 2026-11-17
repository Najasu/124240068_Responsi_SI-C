import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/auth_page.dart';
import 'controllers/favorite_controller.dart';
import 'views/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('users');

  final prefs = await SharedPreferences.getInstance();
  final loggedIn = prefs.getBool('loginData') ?? false;

  Get.put(FavoriteController());

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.loggedIn});

  final bool loggedIn;

  @override
  Widget build(BuildContext context) {
    const seed = Color.fromARGB(255, 255, 0, 0);

    return GetMaterialApp(
      title: 'Rick & Morty Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: seed),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
      ),
      home: loggedIn ? const MainPage() : const AuthPage(isRegister: false),
    );
  }
}
