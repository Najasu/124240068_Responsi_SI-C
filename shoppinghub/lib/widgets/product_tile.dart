import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../utils/helpers.dart';
import '../views/detail_page.dart';
import 'common_widgets.dart';

class ProductTile extends StatelessWidget {
  ProductTile({super.key, required this.product});

  final Product product;
  final wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.to(() => DetailPage(id: product.id)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 76,
                  height: 76,
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  child: ProductImage(url: product.thumbnail, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prettyCategory(product.category),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      money(product.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final w = wishlist.isWishlisted(product.id);
                return IconButton(
                  onPressed: () => toggleWishlist(context, product),
                  icon: Icon(
                    w ? Icons.favorite : Icons.favorite_border,
                    color: w ? Colors.red : null,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
