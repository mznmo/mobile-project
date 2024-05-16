class Product {
  final String name;
  final String description;
  final String imageUrl;
  final double price;


  Product({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
  });

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
    );
  }
}
