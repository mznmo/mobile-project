import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Models/cartModel.dart';
import 'Models/productModel.dart';
import 'cart.dart';
import 'productDetails.dart';
import 'productUpload.dart';
import 'signin.dart';
import 'Models/userModel.dart';

class ProductsPage extends StatefulWidget {
  final User? user;

  ProductsPage({this.user});

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  Cart customerCart = Cart();
  bool isRefreshing = false;
  String selectedCategory = 'All';
  List<String> categories = ['All', 'Office equipment', 'Notebooks & Notepads', 'Printers', 'Computers'];

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
            final String vendorName = productData['vendorName'];
            final String category = productData['category'];

            fetchedProducts.add(Product(
              id: productId,
              name: productName,
              description: productDescription,
              imageUrl: productImageUrl,
              price: productPrice,
              averageRating: 0.0,
              vendorName: vendorName,
              category: category,
            ));
          });

          setState(() {
            products = fetchedProducts;
            filteredProducts = products;
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
    filterProducts();
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
          double totalRating =
              ratings.reduce((value, element) => value + element);
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

  void filterProducts() {
    setState(() {
      if (selectedCategory == 'All') {
        filteredProducts = products;
      } else {
        filteredProducts = products
            .where((product) => product.category == selectedCategory)
            .toList();
      }
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          if (widget.user != null && widget.user!.role == 'vendor')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductUploadPage(user: widget.user),
                  ),
                );
              },
            ),
          if (widget.user != null && widget.user!.role == 'shopper')
            Row(
              children: [
                Text(widget.user!.username),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
          if (widget.user == null || widget.user!.role == null)
            TextButton( // Add a login button
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ),
                );
              },
              child: Text('Login'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                  filterProducts();
                });
              },
              items: categories.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                 
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchProducts,
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final Product product = filteredProducts[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(
                            product: product,
                            cart: customerCart,
                          ),
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
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Vendor: ${product.vendorName}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('\$${product.price.toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: widget.user?.role == 'shopper'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CartPage(
                      cart: customerCart,
                    ),
                  ),
                );
              },
              child: Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}
