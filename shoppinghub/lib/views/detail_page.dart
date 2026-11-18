import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.id});

  final int id;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final wishlist = Get.find<WishlistController>();
  final pageC = PageController();
  Product? product;
  bool isLoading = true;
  String error = '';
  int imageIndex = 0;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  @override
  void dispose() {
    pageC.dispose();
    super.dispose();
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

  Color stockColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock <= 10) return Colors.orange;
    return Colors.green;
  }

  String stockText(int stock) {
    if (stock == 0) return 'Stok habis';
    if (stock <= 10) return 'Stok tinggal $stock';
    return '$stock tersedia';
  }

  Widget stars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        IconData icon = Icons.star_border_rounded;
        if (rating >= i + 1) {
          icon = Icons.star_rounded;
        } else if (rating >= i + 0.5) {
          icon = Icons.star_half_rounded;
        }
        return Icon(icon, size: 20, color: Colors.amber);
      }),
    );
  }

  Widget buildImages(Product p) {
    final cs = Theme.of(context).colorScheme;
    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        height: 320,
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        child: Stack(
          children: [
            PageView.builder(
              controller: pageC,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => imageIndex = i),
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.all(16),
                child: ProductImage(url: images[i], fit: BoxFit.contain),
              ),
            ),
            if (p.hasDiscount)
              Positioned(
                top: 16,
                left: 16,
                child: DiscountBadge(
                  text: '${p.discountPercentage.toStringAsFixed(0)}% OFF',
                ),
              ),
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == imageIndex ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == imageIndex ? cs.primary : cs.outlineVariant,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildBody(Product p) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        buildImages(p),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                prettyCategory(p.category).toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  stars(p.rating),
                  const SizedBox(width: 8),
                  Text(
                    p.rating.toStringAsFixed(2),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Harga + persentase diskon
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    money(p.price),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                  ),
                  if (p.hasDiscount) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Diskon ${p.discountPercentage.toStringAsFixed(2)}%',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (p.hasDiscount)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Setelah diskon: ${money(p.priceAfterDiscount)}',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              const SizedBox(height: 20),
              // Informasi produk
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                color: cs.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      if (p.brand.isNotEmpty)
                        InfoRow(Icons.sell_outlined, 'Brand', p.brand),
                      InfoRow(
                        Icons.category_outlined,
                        'Kategori',
                        prettyCategory(p.category),
                      ),
                      InfoRow(
                        Icons.star_outline_rounded,
                        'Rating',
                        '${p.rating.toStringAsFixed(2)} / 5',
                      ),
                      InfoRow(
                        Icons.percent_rounded,
                        'Diskon',
                        '${p.discountPercentage.toStringAsFixed(2)}%',
                      ),
                      InfoRow(
                        Icons.inventory_2_outlined,
                        'Stok',
                        stockText(p.stock),
                        valueColor: stockColor(p.stock),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Deskripsi',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                p.description,
                style: TextStyle(height: 1.5, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tombol wishlist di bagian bawah: berubah sesuai status
  Widget buildBottomBar(Product p) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga',
                  style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                Text(
                  money(p.price),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Obx(() {
                final w = wishlist.isWishlisted(p.id);
                return FilledButton.icon(
                  onPressed: () => toggleWishlist(context, p),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: w ? Colors.red.withValues(alpha: 0.15) : null,
                    foregroundColor: w ? Colors.red : null,
                  ),
                  icon: Icon(w ? Icons.favorite : Icons.favorite_border),
                  label: Text(w ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = product;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          // Ikon wishlist: outline -> merah penuh kalau sudah di wishlist
          if (p != null)
            Obx(() {
              final w = wishlist.isWishlisted(p.id);
              return IconButton(
                tooltip: w ? 'Hapus dari wishlist' : 'Tambah ke wishlist',
                onPressed: () => toggleWishlist(context, p),
                icon: Icon(
                  w ? Icons.favorite : Icons.favorite_border,
                  color: w ? Colors.red : null,
                ),
              );
            }),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (error.isNotEmpty || p == null)
              ? MessageView(icon: Icons.wifi_off_rounded, text: error, onRetry: fetch)
              : buildBody(p),
      bottomNavigationBar: (p == null || isLoading) ? null : buildBottomBar(p),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow(this.icon, this.label, this.value, {super.key, this.valueColor});

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(icon),
      title: Text(label, style: const TextStyle(fontSize: 12)),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ),
    );
  }
}
