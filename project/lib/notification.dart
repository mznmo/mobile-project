import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailService {

  static Future<void> sendEmailToUsers(String productName) async {
    final String emailSubject = 'New Product Added: $productName';
    final String emailBody = 'A new product "$productName" has been added. Check it out on our store!';

    final String usersUrl = 'https://mobile2-b7914-default-rtdb.europe-west1.firebasedatabase.app/users.json';

    try {
      final usersResponse = await http.get(Uri.parse(usersUrl));

      if (usersResponse.statusCode == 200) {
        final dynamic responseBody = usersResponse.body;

        if (responseBody != null && responseBody is String && responseBody.isNotEmpty) {
          final Map<String, dynamic> usersData = jsonDecode(responseBody);

          if (usersData.isNotEmpty) {
            usersData.forEach((userId, userData) {
              final String email = userData['email'];
              final String role = userData['role'];

              if (role == 'shopper') {
                sendEmail(email, emailSubject, emailBody);
              }
            });
          } else {
            throw Exception('No users found');
          }
        } else {
          throw Exception('Invalid or empty response body');
        }
      } else {
        throw Exception('Failed to fetch users: ${usersResponse.reasonPhrase}');
      }
    } catch (e) {
      print('Error fetching or processing users: $e');
    }
  }

  static Future<void> sendEmail(String recipientEmail, String subject, String body) async {
    final apiKey = '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';
    final sendGridUrl = 'https://api.sendgrid.com/v3/mail/send';

    final emailContent = {
      "personalizations": [
        {
          "to": [
            {"email": recipientEmail}
          ],
          "subject": subject
        }
      ],
      "from": {"email": "elshinymazen@gmail.com"},
      "content": [
        {
          "type": "text/plain",
          "value": body
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(sendGridUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(emailContent),
      );

      if (response.statusCode != 202) {
        throw Exception('Failed to send email: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
