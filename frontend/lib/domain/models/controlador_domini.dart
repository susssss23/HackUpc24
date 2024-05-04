import "dart:convert";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";

class ControladorDomini {
  final apiUrl = "http://192.168.50.234:8000/api/post";

  Future<String> sendPostRequest(String question, String language) async {
    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "language": language,
        }));

    if (response.statusCode == 200) {
      dynamic jsonResponse = jsonDecode(response.body);
      // Check if jsonResponse is a List or a Map

      if (jsonResponse.containsKey('response')) {
        // Access the value of the 'attribute'
        String attributeValue = jsonResponse['response'];
        return attributeValue;
      } else {
        throw Exception('Attribute not found in JSON response');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
