import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> makeGETRequest(String url) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      return json.decode(response.body);
    } else {
      // If the server did not return a 200 OK response, throw an exception.
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Handle any errors that occurred during the HTTP request
    print('Error making GET request: $error');
    rethrow;
  }
}