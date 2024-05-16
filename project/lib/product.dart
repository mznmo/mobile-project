import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // Import path_provider package
import 'productModel.dart';
import 'productUpload.dart';

class ProductsPage extends StatefulWidget {
  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product> products = [];
  bool isRefreshing = false; // Track refresh state

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json';

    try {
      final response = await http.get(Uri.parse(databaseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Product> fetchedProducts = [];
        data.forEach((productId, productData) {
          fetchedProducts.add(Product(
            name: productData['name'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'].toDouble(),
          ));
        });

        setState(() {
          products = fetchedProducts;
        });
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Product newProduct) async {
    // Add the product to the database
    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json';

    try {
      final response = await http.post(
        Uri.parse(databaseUrl),
        body: jsonEncode({
          'name': newProduct.name,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );

      if (response.statusCode == 200) {
        print('Product uploaded successfully');
        fetchProducts(); // Refresh products list
      } else {
        throw Exception('Failed to upload product');
      }
    } catch (e) {
      print('Error uploading product: $e');
    }
  }

  Future<void> _refreshProducts() async {
    setState(() {
      isRefreshing = true; // Set refreshing state
    });

    await fetchProducts(); // Fetch products again

    setState(() {
      isRefreshing = false; // Reset refreshing state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final Product product = products[index];
            return ListTile(
              leading: Container(
                width: 80,
                height: 80,
                child: Image.file(
                  File(product.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(product.name),
              subtitle: Text(product.description),
              trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductUploadPage()),
          ).then((newProduct) {
            if (newProduct != null && newProduct is Product) {
              addProduct(newProduct);
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
