import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';
import '../widgets/product_tile.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = Get.find<WishlistController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Wishlist (${wishlist.items.length})')),
      ),
      body: Obx(() {
        if (wishlist.items.isEmpty) {
          return const MessageView(
            icon: Icons.favorite_border,
            text: 'Wishlist masih kosong.\n'
                'Tekan ikon hati pada produk untuk menambahkannya.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: wishlist.items.length,
          itemBuilder: (context, i) {
            final product = wishlist.items[i];
            return Dismissible(
              key: ValueKey(product.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => toggleWishlist(context, product),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              child: ProductTile(product: product),
            );
          },
        );
      }),
    );
  }
}
