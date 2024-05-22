import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'notification_service.dart'; // Import the notification service

class ProductUploadPage extends StatefulWidget {
  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _imageFile;
  final NotificationService _notificationService = NotificationService(); // Initialize the notification service

  Future<void> _uploadProduct() async {
    if (_imageFile == null) {
      print('No image selected');
      return;
    }

    try {
      String imageUrl = await _uploadImageToFirebase(_imageFile!);
      String name = _nameController.text;
      String description = _descriptionController.text;
      double price = double.tryParse(_priceController.text) ?? 0.0;

      final String databaseUrl =
          'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/products.json';

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
        await _notificationService.sendNotification(
            'New Product Added', 'A vendor has added a new product.');
        Navigator.pop(context);
      } else {
        throw Exception('Failed to upload product');
      }
    } catch (e) {
      print('Error uploading product: $e');
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    String fileName = path.basename(image.path);
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('products/$fileName');
    UploadTask uploadTask = firebaseStorageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
    return await taskSnapshot.ref.getDownloadURL();
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
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null) {
                  setState(() {
                    _imageFile = File(result.files.single.path!);
                    _imageUrlController.text = _imageFile!.path;
                  });
                } else {
                  // User canceled the picker
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
