import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class WishlistController extends GetxController {
  final items = <Product>[].obs;
  final username = ''.obs;
  final Box box = Hive.box('wishlist');

  @override
  void onInit() {
    load();
    super.onInit();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    username.value = prefs.getString('username') ?? '';
    if (username.value == '') {
      items.clear();
      return;
    }

    final raw = box.get(username.value, defaultValue: []);
    final list = List<String>.from(raw);
    items.assignAll(list.map((e) => Product.fromJson(jsonDecode(e))));
  }

  void clear() {
    items.clear();
    username.value = '';
  }

  bool isWishlisted(int id) => items.any((p) => p.id == id);

  bool toggle(Product p) {
    final exists = isWishlisted(p.id);
    if (exists) {
      items.removeWhere((e) => e.id == p.id);
    } else {
      items.add(p);
    }
    save();
    return !exists;
  }

  void save() {
    if (username.value == '') return;
    box.put(
      username.value,
      items.map((p) => jsonEncode(p.toJson())).toList(),
    );
  }
}
