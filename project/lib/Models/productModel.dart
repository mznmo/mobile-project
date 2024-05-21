class Product {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String category;
  final String vendorName;
  double averageRating;

  Product({
    String? id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.vendorName,
    required this.averageRating,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'category': category,
      'vendorName': vendorName,
      'averageRating': averageRating,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: json['price'].toDouble(),
      category: json['category'],
      vendorName: json['vendorName'],
      averageRating: json['averageRating'].toDouble(),
    );
  }
}
