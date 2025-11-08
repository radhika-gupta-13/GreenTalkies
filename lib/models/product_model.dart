class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? discount; // optional field

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.discount,
  });

  // Factory constructor to safely create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] != null ? json['id'] as String : '',
      name: json['name'] != null ? json['name'] as String : 'Unknown Product',
      description: json['description'] != null ? json['description'] as String : '',
      price: (json['price'] != null)
          ? ((json['price'] is int)
              ? (json['price'] as int).toDouble()
              : json['price'] as double)
          : 0.0,
      imageUrl: json['imageUrl'] != null && (json['imageUrl'] as String).isNotEmpty
          ? json['imageUrl'] as String
          : 'assets/default_image.png',
      discount: json['discount'] != null ? json['discount'] as String : null,
    );
  }

  // Optional: toJson method for sending to backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      if (discount != null) 'discount': discount,
    };
  }
}
