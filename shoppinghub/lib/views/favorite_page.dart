import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/character_tile.dart';
import '../controllers/favorite_controller.dart';
import '../widgets/common_widgets.dart';

class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});

  final fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (fav.favorites.isEmpty) {
        return const MessageView(
          icon: Icons.favorite_border,
          text: 'Belum ada wishlist produk.\n'
              'Tekan ikon hati pada karakter untuk menambahkannya.',
        );
      }

      return ListView.builder(
        itemCount: fav.favorites.length,
        itemBuilder: (context, i) {
          final product = fav.favorites[i];
          return Dismissible(
            key: ValueKey(product.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => fav.remove(product),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: ProductTile(product: product),
          );
        },
      );
    });
  }
}
