class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? discount;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.discount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] != null ? json['_id'] as String : '',
      name: json['name'] != null ? json['name'] as String : 'Unknown Product',
      description: json['description'] != null ? json['description'] as String : '',
      price: (json['price'] != null)
          ? (json['price'] is int
              ? (json['price'] as int).toDouble()
              : (json['price'] as num).toDouble())
          : 0.0,
      imageUrl: (json['imageUrl'] != null && (json['imageUrl'] as String).isNotEmpty)
          ? json['imageUrl'] as String
          : 'assets/default_image.png',
      discount: json['discount'] != null ? json['discount'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, 
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      if (discount != null) 'discount': discount,
    };
  }
}
