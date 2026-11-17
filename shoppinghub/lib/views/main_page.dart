import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_page.dart';
import '../controllers/favorite_controller.dart';
import 'favorite_page.dart';
import 'home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  final fav = Get.find<FavoriteController>();

  final pages = [const HomePage(), FavoritePage()];
  final titles = ['Product List', 'Wishlist'];

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('username');
    fav.clear();
    Get.offAll(() => const AuthPage(isRegister: false));
  }

  void confirmLogout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          FilledButton(onPressed: logout, child: const Text('Keluar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: confirmLogout),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.shopping_basket_outlined),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Obx(() => Badge(
                  isLabelVisible: fav.favorites.isNotEmpty,
                  label: Text('${fav.favorites.length}'),
                  child: const Icon(Icons.favorite_border),
                )),
            selectedIcon: const Icon(Icons.favorite_border_outlined),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }
}
