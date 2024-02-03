import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';

class NewsContentScreen extends StatefulWidget {
  final String url;

  NewsContentScreen({required this.url});

  @override
  _NewsContentScreenState createState() => _NewsContentScreenState();
}

class _NewsContentScreenState extends State<NewsContentScreen> {
  late Future<Map<String, dynamic>> _articleData;

  @override
  void initState() {
    super.initState();
    _articleData = _fetchArticleData();
  }

  Future<Map<String, dynamic>> _fetchArticleData() async {
    try {
      final response = await http.get(Uri.parse(widget.url));

      if (response.statusCode == 200) {
        // print(response.body); // Check the API response in the console
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load article content. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load article content. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tuko News'),
        backgroundColor: Color(0xFFC21516),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _articleData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!['data'] == null) {
            return Center(child: Text('Invalid article data'));
          } else {
            String text = snapshot.data!['data']['text'] ?? '';
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Markdown(
                data: text,
                styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                    .copyWith(textScaleFactor: 1.2),
              ),
            );
          }
        },
      ),
    );
  }
}
