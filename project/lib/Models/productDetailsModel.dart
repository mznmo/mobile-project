import 'productModel.dart';

class ProductDetails {
  final Product product;
  final List<Comment> comments;
  final double averageRating;

  ProductDetails({
    required this.product,
    required this.comments,
    required this.averageRating,
  });
}

class Comment {
  final String text;
  final double rating;

  Comment({
    required this.text,
    required this.rating,
  });
}
