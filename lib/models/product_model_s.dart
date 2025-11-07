class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String? discount; // <-- optional

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.discount,
  });
}
