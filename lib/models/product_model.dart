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

  // Factory constructor to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) 
          ? (json['price'] as int).toDouble() 
          : json['price'] as double,
      imageUrl: json['imageUrl'],
      discount: json['discount'], // may be null
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
