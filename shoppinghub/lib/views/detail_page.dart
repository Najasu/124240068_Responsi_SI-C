import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/favorite_controller.dart';
import '../models/product.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.id});

  final int id;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final fav = Get.find<FavoriteController>();
  Product? product;
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    setState(() {
      isLoading = true;
      error = '';
    });
    try {
      final data = await ApiService.getProduct(widget.id);
      if (!mounted) return;
      setState(() {
        product = data;
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

  Widget buildBody(Product ch) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProductImages(url: ch.images, width: double.infinity, height: 320, radius: 24),
        const SizedBox(height: 16),
        Text(
          ch.name,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: CategoryBadge(category: ch.category),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                InfoRow(Icons.description_outlined, 'Description', ch.description),
                InfoRow(Icons.category_outlined, 'Category', ch.category),
                InfoRow(Icons.monetization_on_outlined, 'Price', ch.price),
                InfoRow(Icons.discount_outlined, 'Discount', ch.discount),
                InfoRow(Icons.shopping_bag_outlined, 'Brand', ch.brand),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tombol favorit: teks & ikon berubah sesuai status
        Obx(() {
          final isFav = fav.isFavorite(ch.id);
          return FilledButton.icon(
            onPressed: () => fav.toggle(ch),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            label: Text(isFav ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist'),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ch = product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Karakter'),
        actions: [
          if (ch != null)
            Obx(() {
              final isFav = fav.isFavorite(ch.id);
              return IconButton(
                onPressed: () => fav.toggle(ch),
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
              );
            }),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error.isNotEmpty || ch == null)
              ? MessageView(icon: Icons.wifi_off_rounded, text: error, onRetry: fetch)
              : buildBody(ch),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.icon, this.label, this.value, {super.key});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}
