import "dart:convert";
import 'package:http/http.dart' as http;
import "package:flutter/material.dart";

class ControladorDomini {
  final apiUrl = "http://192.168.50.234:8000/api/post";

  Future<List<String>> sendPostRequest(String question, String language) async {
    var response = await http.post(Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "question": question,
          "language": language,
        }));

    if (response.statusCode == 200) {
      dynamic jsonResponse = jsonDecode(response.body);
      // Check if jsonResponse is a List or a Map
      if (jsonResponse is List) {
        return jsonResponse.cast<String>();
      } else {
        // If it's not a List, handle it accordingly
        throw Exception('Expected a List, but received a Map');
      }
    } else {
      throw Exception('Failed to load data from API');
    }
  }
}
