import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../utils/helpers.dart';

class FavoriteController extends GetxController {
  final favorites = <Product>[].obs;
  String key = '';

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username == null) return;

    key = 'favorites_$username';
    final list = prefs.getStringList(key) ?? [];
    favorites.assignAll(list.map((e) => Product.fromJson(jsonDecode(e))));
  }

  void clear() {
    favorites.clear();
    key = '';
  }

  bool isFavorite(int id) => favorites.any((c) => c.id == id);

  void toggle(Product c) => isFavorite(c.id) ? remove(c) : add(c);

  void add(Product c) {
    favorites.add(c);
    save();
    showSnack('Favorit', '${c.name} ditambahkan ke favorit');
  }

  void remove(Product c) {
    favorites.removeWhere((e) => e.id == c.id);
    save();
    showSnack('Favorit', '${c.name} dihapus dari favorit');
  }

  Future<void> save() async {
    if (key == '') return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      key,
      favorites.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }
}
