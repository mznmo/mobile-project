import 'package:flutter/material.dart';
import 'Models/cartModel.dart';

class CartPage extends StatefulWidget {
  final Cart cart;

  CartPage({required this.cart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: widget.cart.items.isEmpty
          ? Center(
              child: Text('Your cart is empty'),
            )
          : ListView.builder(
              itemCount: widget.cart.items.length,
              itemBuilder: (context, index) {
                final CartItem item = widget.cart.items[index];
                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      widget.cart.removeProduct(item.product);
                      if (widget.cart.items.isEmpty) {
                        Navigator.pop(context); // Close the cart page if it becomes empty
                      }
                    });
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    leading: Image.network(
                      item.product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      'Quantity: ${item.quantity} - \$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle),
                      onPressed: () {
                        setState(() {
                          widget.cart.removeProduct(item.product);
                          if (widget.cart.items.isEmpty) {
                            Navigator.pop(context); // Close the cart page if it becomes empty
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: widget.cart.items.isNotEmpty
          ? Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: \$${widget.cart.getTotalPrice().toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Order Placed Successfully')),
                      );
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
