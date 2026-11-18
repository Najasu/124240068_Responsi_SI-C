import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_card.dart';
import 'auth_page.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final wishlist = Get.find<WishlistController>();

  List<Product> products = [];
  List<String> categories = [];
  bool isLoading = true;
  String error = '';
  String category = '';
  String query = '';
  String sort = 'default';

  final sorts = {
    'default': 'Default',
    'low': 'Harga termurah',
    'high': 'Harga termahal',
    'rating': 'Rating tertinggi',
  };

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetch();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await ApiService.getCategories();
      if (!mounted) return;
      setState(() => categories = data);
    } catch (e) {}
  }

  Future<void> fetch() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final data = await ApiService.getProducts(category: category, query: query);
      if (!mounted) return;
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = errorMessage;
        isLoading = false;
      });
    }
  }

  List<Product> get visibleProducts {
    final list = [...products];
    if (sort == 'low') list.sort((a, b) => a.price.compareTo(b.price));
    if (sort == 'high') list.sort((a, b) => b.price.compareTo(a.price));
    if (sort == 'rating') list.sort((a, b) => b.rating.compareTo(a.rating));
    return list;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('loginData', false);
    await prefs.remove('username');
    wishlist.clear();
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

  Widget buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return MessageView(icon: Icons.wifi_off_rounded, text: error, onRetry: fetch);
    }
    final list = visibleProducts;
    if (list.isEmpty) {
      return const MessageView(
        icon: Icons.search_off_rounded,
        text: 'Produk tidak ditemukan',
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${list.length} produk',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              mainAxisExtent: 290,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: list.length,
            itemBuilder: (context, i) => ProductCard(product: list[i]),
          ),
        ),
      ],
    );
  }

  Widget categoryChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: category == value,
        onSelected: (_) {
          category = value;
          fetch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        titleSpacing: 16,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ShoppingHub',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Obx(() => Text(
                  'Halo, ${wishlist.username.value}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: cs.onSurfaceVariant,
                  ),
                )),
          ],
        ),
        actions: [
          Obx(() => IconButton(
                tooltip: 'Wishlist',
                onPressed: () => Get.to(() => const WishlistPage()),
                icon: Badge(
                  isLabelVisible: wishlist.items.isNotEmpty,
                  label: Text('${wishlist.items.length}'),
                  child: const Icon(Icons.favorite_border),
                ),
              )),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: confirmLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      query = v.trim();
                      fetch();
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Urutkan',
                  onSelected: (v) => setState(() => sort = v),
                  itemBuilder: (context) => [
                    for (final s in sorts.entries)
                      CheckedPopupMenuItem<String>(
                        value: s.key,
                        checked: sort == s.key,
                        child: Text(s.value),
                      ),
                  ],
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.swap_vert_rounded),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                categoryChip('Semua', ''),
                for (final c in categories) categoryChip(prettyCategory(c), c),
              ],
            ),
          ),
          Expanded(child: buildBody()),
        ],
      ),
    );
  }
}
