import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/character_tile.dart';
import '../models/product.dart';
import '../utils/helpers.dart';
import '../widgets/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> products = [];
  bool isLoading = true;
  String error = '';
  String status = ''; 
  String query = '';

  final filters = {'Semua': '', 'Beauty': 'beauty', 'Fragrances': 'fragreances', 'Furniture': 'furniture', 'Groceries': 'groceries'};

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
      final data = await ApiService.getProducts(category: status, name: query);
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

  Widget buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (error.isNotEmpty) {
      return MessageView(icon: Icons.wifi_off_rounded, text: error, onRetry: fetch);
    }
    if (products.isEmpty) {
      return const MessageView(
        icon: Icons.search_off_rounded,
        text: 'Produk tidak ditemukan',
      );
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) => ProductTile(product: products[i]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
        // Filter status
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: filters.entries.map((f) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f.key),
                  selected: status == f.value,
                  onSelected: (_) {
                    status = f.value;
                    fetch();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(child: buildBody()),
      ],
    );
  }
}
