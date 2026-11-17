import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const host = 'dummyjson.com/products';

  static Future<Map<String, dynamic>?> getPage(
    int page,
    String status,
    String name,
  ) async {
    final uri = Uri.https(host, '/category-list', {
      'page': '$page',
      if (status != '') 'status': status,
      if (name != '') 'name': name,
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<Product>> getProducts({
    String category = '',
    String name = '',
  }) async {
    final first = await getPage(1, category, name);
    if (first == null) return [];

    final int totalPages = first['info']['pages'];
    List<Product> all = [];
    for (var e in first['results']) {
      all.add(Product.fromJson(e));
    }

    final others = await Future.wait([
      for (int p = 2; p <= totalPages; p++) getPage(p, category, name),
    ]);
    for (var data in others) {
      if (data == null) continue;
      for (var e in data['results']) {
        all.add(Product.fromJson(e));
      }
    }
    return all;
  }

  static Future<Product> getProduct(int id) async {
    final uri = Uri.https(host, '/{id}$id');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }
}
