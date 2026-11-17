class Product {
  final int id;
  final String name;
  final String description;
  final String price;
  final String rating;
  final String stock;
  final String brand;
  final String category;
  final String discount;
  final String images;
  final String reviews;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.category,
    required this.discount,
    required this.images,
    required this.reviews,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? '',
      rating: json['rating'] ?? '',
      stock: json['stock'] ?? '',
      brand: json['brand'] ?? '',
      category: json['category'] ?? [],
      discount: json['discount'] ?? [],
      images: json['images'] ?? [],
      reviews: json['reviews'] ?? [],
    );
  }

  // Untuk menyimpan favorit (bentuknya sama dengan JSON API)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'rating': rating,
        'stock': stock,
        'brand': brand,
        'category': category,
        'discount' : discount,
        'images' : images,
        'reviews' : reviews,   
      };
}