import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse(widget.url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load article content');
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
          } else {
            return _buildArticleContent(snapshot.data!);
          }
        },
      ),
    );
  }

  Widget _buildArticleContent(Map<String, dynamic> articleData) {
    String author = articleData['data']['author'];
    String date = articleData['data']['date'];
    String title = articleData['data']['title'];
    List<String> images = List.castFrom(articleData['data']['images']);
    String text = articleData['data']['text'];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Author: $author',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 8),
            Text(
              'Date: $date',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            if (images.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    images.first, // Display only the first image for simplicity
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Content:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
