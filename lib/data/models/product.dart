/// Un produit de la boutique STYMA.
class Product {
  final String id;
  final String name;
  final String? category;
  final double price;
  final String? imageUrl;
  final String? description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.category,
    this.imageUrl,
    this.description,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['image_url'] as String?,
      description: map['description'] as String?,
    );
  }

  /// Prix formaté « 25 € » ou « 24,90 € ».
  String get formattedPrice {
    if (price == price.roundToDouble()) {
      return '${price.toStringAsFixed(0)} €';
    }
    return '${price.toStringAsFixed(2).replaceAll('.', ',')} €';
  }
}
