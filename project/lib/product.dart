import 'package:flutter/material.dart';
import 'productModel.dart'; // Import the Product model

class ProductsPage extends StatelessWidget {
  // Dummy product data (replace with your actual product list)
  final List<Product> products = [
    Product(
      name: 'Product 1',
      description: 'Description of Product 1',
      imageUrl: 'https://via.placeholder.com/150',
      price: 19.99,
    ),
    Product(
      name: 'Product 2',
      description: 'Description of Product 2',
      imageUrl: 'https://via.placeholder.com/150',
      price: 29.99,
    ),
    Product(
      name: 'Product 3',
      description: 'Description of Product 3',
      imageUrl: 'https://via.placeholder.com/150',
      price: 39.99,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final Product product = products[index];
          return ListTile(
            leading: Image.network(product.imageUrl),
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Text('\$${product.price.toStringAsFixed(2)}'),
            onTap: () {
              // Handle tapping on a product (e.g., navigate to product details)
              // For simplicity, you can show a dialog with product details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(product.name),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.network(product.imageUrl),
                      Text(product.description),
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
