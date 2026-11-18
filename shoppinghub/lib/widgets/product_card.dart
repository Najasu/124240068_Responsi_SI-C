import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../utils/helpers.dart';
import '../views/detail_page.dart';
import 'common_widgets.dart';

class ProductCard extends StatelessWidget {
  ProductCard({super.key, required this.product});

  final Product product;
  final wishlist = Get.find<WishlistController>();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.to(() => DetailPage(id: product.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: ProductImage(url: product.thumbnail, fit: BoxFit.contain),
                  ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: DiscountBadge(
                        text: '-${product.discountPercentage.round()}%',
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Obx(() {
                      final w = wishlist.isWishlisted(product.id);
                      return Material(
                        color: cs.surface.withValues(alpha: 0.85),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => toggleWishlist(context, product),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              w ? Icons.favorite : Icons.favorite_border,
                              size: 20,
                              color: w ? Colors.red : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 36,
                    child: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          money(product.price),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
