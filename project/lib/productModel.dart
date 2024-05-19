class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  double averageRating;

  Product({
    String? id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.averageRating,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      averageRating: json['averageRating'].toDouble(),
    );
  }
}
