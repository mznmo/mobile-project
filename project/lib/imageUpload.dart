import 'dart:io';
import 'package:http/http.dart' as http;

Future<String> uploadImageToFirebaseStorage(File imageFile, String fileName) async {
  final String uploadUrl = 'gs://mobile2-b7914.appspot.com/images/$fileName';

  try {
    final response = await http.post(
      Uri.parse(uploadUrl),
      body: imageFile.readAsBytesSync(),
      headers: {
        'Content-Type': 'image/jpeg',
      },
    );

    if (response.statusCode == 200) {
      return uploadUrl;
    } else {
      throw Exception('Failed to upload image');
    }
  } catch (e) {
    throw Exception('Failed to upload image: $e');
  }
}
