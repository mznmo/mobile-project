import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';


class ProductUploadPage extends StatefulWidget {
  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Function to upload product to database
  Future<void> _uploadProduct() async {
    String name = _nameController.text;
    String description = _descriptionController.text;
    String imageUrl = _imageUrlController.text;
    double price = double.tryParse(_priceController.text) ?? 0.0;

    final String databaseUrl =
        'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json'; // Replace with your database URL

    try {
      final response = await http.post(
        Uri.parse(databaseUrl),
        body: json.encode({
          'name': name,
          'description': description,
          'imageUrl': imageUrl,
          'price': price,
        }),
      );

      if (response.statusCode == 200) {
        print('Product uploaded successfully');
        Navigator.pop(context); // Close the upload page after successful upload
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
            ElevatedButton(
              onPressed: () async {
                // File Picker to choose image
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  _imageUrlController.text = result.files.single.path!;
                } else {
                  // User canceled the file picking
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