class Fertilizer {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Fertilizer({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory Fertilizer.fromJson(Map<String, dynamic> json) {
    return Fertilizer(
      id: json['_id'] != null ? json['_id'] as String : '',
      name: json['name'] != null ? json['name'] as String : 'Unknown Fertilizer',
      description: json['description'] != null ? json['description'] as String : '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      imageUrl: json['imageUrl'] != null && (json['imageUrl'] as String).isNotEmpty
          ? json['imageUrl'] as String
          : 'assets/default_image.png',
    );
  }
}
