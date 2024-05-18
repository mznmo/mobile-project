import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'productDetails.dart';
import 'productDetailsModel.dart';
import 'productModel.dart';
import 'productUpload.dart';
import 'signin.dart';

enum UserRole {
  shopper,
  vendor,
}

class ProductsPage extends StatefulWidget {
  final UserRole userRole;

  ProductsPage({required this.userRole});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String productsUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json';

    try {
      final productsResponse = await http.get(Uri.parse(productsUrl));


      if (productsResponse.statusCode == 200) {
        final dynamic responseBody = productsResponse.body;

     
        if (responseBody != null && responseBody.isNotEmpty) {
          final Map<String, dynamic> productsData = jsonDecode(responseBody);
          List<Product> fetchedProducts = [];


          productsData.forEach((productId, productData) {
            final String productName = productData['name'];
            final String productDescription = productData['description'];
            final String productImageUrl = productData['imageUrl'];
            final double productPrice =
                double.parse(productData['price'].toString());

            fetchedProducts.add(Product(
              id: productId,
              name: productName,
              description: productDescription,
              imageUrl: productImageUrl,
              price: productPrice,
              averageRating: 0.0,
            ));
          });

          setState(() {
            products = fetchedProducts;
            calculateAverageRatings();
          });
        } else {
          throw Exception('Empty or null response body');
        }
      } else {
        throw Exception(
            'Failed to fetch products: ${productsResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }


  void calculateAverageRatings() async {
    for (int i = 0; i < products.length; i++) {
      double averageRating =
          await fetchAndCalculateAverageRating(products[i].id);
      setState(() {
        products[i].averageRating = averageRating;
      });
    }
  }


  Future<double> fetchAndCalculateAverageRating(String productId) async {
    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/$productId/comments.json';

    try {
      final response = await http.get(Uri.parse(databaseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<double> ratings = [];
        data.forEach((commentId, commentData) {
          ratings.add(commentData['rating'].toDouble());
        });
        if (ratings.isNotEmpty) {
          double totalRating = ratings.reduce((value, element) => value + element);
          return totalRating / ratings.length;
        } else {
          return 0.0;
        }
      } else {
        throw Exception('Failed to fetch comments for product $productId');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final Product product = products[index];
            return ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailsPage(product: product),
                  ),
                );
              },
              leading: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(product.imageUrl),
                  ),
                ),
              ),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.description),
                  SizedBox(height: 4),
                  Text(
                    'Rating: ${product.averageRating.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
      floatingActionButton: widget.userRole == UserRole.vendor
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductUploadPage()),
                ).then((newProduct) {
                  if (newProduct != null && newProduct is Product) {
                  }
                });
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}
