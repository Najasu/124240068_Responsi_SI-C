import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';

const errorMessage =
    'Gagal memuat data.\nPeriksa koneksi internet kamu lalu coba lagi.';

void showSnack(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    backgroundColor: Colors.black87,
    colorText: Colors.white,
    duration: const Duration(seconds: 2),
  );
}

String money(double value) => '\$${value.toStringAsFixed(2)}';

String prettyCategory(String slug) {
  return slug
      .split('-')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

void toggleWishlist(BuildContext context, Product product) {
  final added = Get.find<WishlistController>().toggle(product);

  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: added ? Colors.green.shade600 : Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
      content: Row(
        children: [
          Icon(added ? Icons.favorite : Icons.heart_broken, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              added
                  ? '${product.title} ditambahkan ke wishlist'
                  : '${product.title} dihapus dari wishlist',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
