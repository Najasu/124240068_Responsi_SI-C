import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/detail_page.dart';
import '../controllers/favorite_controller.dart';
import '../models/product.dart';
import 'common_widgets.dart';

class ProductTile extends StatelessWidget {
  ProductTile({super.key, required this.product});

  final Product product;
  final fav = Get.find<FavoriteController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Get.to(() => DetailPage(id: product.id)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ProductImages(url: product.images, width: 64, height: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    CategoryBadge(category: product.category),
                  ],
                ),
              ),
              Obx(() {
                final isFav = fav.isFavorite(product.id);
                return IconButton(
                  onPressed: () => fav.toggle(product),
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: Colors.redAccent,
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
