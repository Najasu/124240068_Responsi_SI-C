import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const host = 'dummyjson.com';
  static const limit = '200';

  static Future<dynamic> get(String path, [Map<String, String>? query]) async {
    final uri = Uri.https(host, path, query);
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load $path (${response.statusCode})');
  }

  static Future<List<Product>> getProducts({
    String category = '',
    String query = '',
  }) async {
    String path = '/products';
    if (query != '') {
      path = '/products/search';
    } else if (category != '') {
      path = '/products/category/$category';
    }

    final data = await get(path, {
      'limit': limit,
      if (query != '') 'q': query,
    });

    List results = data['products'];
    var list = results.map((e) => Product.fromJson(e)).toList();

    if (query != '' && category != '') {
      list = list.where((p) => p.category == category).toList();
    }
    return list;
  }

  static Future<Product> getProduct(int id) async {
    final data = await get('/products/$id');
    return Product.fromJson(data);
  }

  static Future<List<String>> getCategories() async {
    final data = await get('/products/category-list');
    return List<String>.from(data);
  }
}
