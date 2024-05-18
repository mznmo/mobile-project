import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'productDetailsModel.dart';
import 'productModel.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  ProductDetailsPage({required this.product});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  List<Comment> comments = [];
  double averageRating = 0.0;
  TextEditingController commentController = TextEditingController();
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchComments();
  }

  Future<void> fetchComments() async {
    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/${widget.product.id}/comments.json';

    try {
      final response = await http.get(Uri.parse(databaseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Comment> fetchedComments = [];
        data.forEach((commentId, commentData) {
          fetchedComments.add(Comment(
            text: commentData['text'],
            rating: commentData['rating'].toDouble(),
          ));
        });

        setState(() {
          comments = fetchedComments;
          calculateAverageRating();
        });
      } else {
        throw Exception('Failed to fetch comments');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  void calculateAverageRating() {
    if (comments.isNotEmpty) {
      double totalRating = comments.map((c) => c.rating).reduce((a, b) => a + b);
      averageRating = totalRating / comments.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.product.imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                ),
                SizedBox(height: 16),
                Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(widget.product.description),
                SizedBox(height: 16),
                Text(
                  'Price: \$${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Average Rating: ${averageRating.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Comments:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                buildCommentsList(),
                SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Write a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                RatingBar.builder(
                  initialRating: userRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 40,
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      userRating = rating;
                    });
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (commentController.text.isNotEmpty && userRating > 0) {
                      addCommentAndRating(commentController.text, userRating);
                    }
                  },
                  child: Text('Add Comment & Rating'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCommentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          title: Text(comment.text),
          subtitle: Text('Rating: ${comment.rating.toStringAsFixed(1)}'),
        );
      },
    );
  }

  void addCommentAndRating(String commentText, double rating) {
    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/${widget.product.id}/comments.json';

    try {
      http.post(
        Uri.parse(databaseUrl),
        body: jsonEncode({
          'text': commentText,
          'rating': rating,
        }),
      ).then((response) {
        if (response.statusCode == 200) {
          setState(() {
            comments.add(Comment(text: commentText, rating: rating));
            calculateAverageRating();
            commentController.clear();
            userRating = 0.0;
          });
        } else {
          throw Exception('Failed to add comment and rating');
        }
      });
    } catch (e) {
      print('Error adding comment and rating: $e');
    }
  }
}
