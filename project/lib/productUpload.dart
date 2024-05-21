import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'notification.dart';
import 'Models/userModel.dart';

class ProductUploadPage extends StatefulWidget {
  final User? user;

  ProductUploadPage({Key? key, this.user}) : super(key: key);

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String selectedCategory = 'Office equipment'; // Default category

  Future<void> _uploadProduct() async {
    String name = _nameController.text;
    String description = _descriptionController.text;
    String imageUrl = _imageUrlController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    String vendorName = widget.user?.username ?? '';

    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json';

    try {
      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode({
          'name': name,
          'description': description,
          'imageUrl': imageUrl,
          'price': price,
          'category': selectedCategory,
          'vendorName': vendorName,
        }),
      );

      if (response.statusCode == 200) {
        print('Product uploaded successfully');
        // Notify users
        await EmailService.sendEmailToUsers(name);
        Navigator.pop(context);
      } else {
        throw Exception('Failed to upload product');
      }
    } catch (e) {
      print('Error uploading product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display the vendor's name
            Text('Vendor: ${widget.user?.username ?? "Unknown"}'),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20.0),
            DropdownButton<String>(
              value: selectedCategory,
              items: <String>[
                'Office equipment',
                'Notebooks & Notepads',
                'Printers',
                'Computers'
              ].map((String value) {
               
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  _imageUrlController.text = result.files.single.path!;
                }
              },
              child: Text('Choose Image'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _uploadProduct,
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
