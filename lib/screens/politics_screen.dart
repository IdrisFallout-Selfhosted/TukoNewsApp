import 'package:flutter/material.dart';
import 'package:tukonewsapp/models/article.dart';
import 'package:tukonewsapp/services/api_service.dart';
import 'package:tukonewsapp/screens/news_content_screen.dart';

class PoliticsScreen extends StatefulWidget {
  @override
  _PoliticsScreenState createState() => _PoliticsScreenState();
}

class _PoliticsScreenState extends State<PoliticsScreen> {
  final String apiUrlBase = 'https://tuko.waithakasam.com/politics/';
  int currentPage = 1;
  List<Article> articles = [];
  bool isLoading = false;
  bool hasMorePages = true; // Track whether there are more pages to fetch
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();

    // Add a listener to the scroll controller to detect when reaching the end of the list
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    if (isLoading || !hasMorePages) return;

    setState(() {
      isLoading = true;
    });

    try {
      final Map<String, dynamic> data = await makeGETRequest('$apiUrlBase$currentPage');

      final List<dynamic> articlesData = data['data'];

      if (articlesData.isNotEmpty) {
        setState(() {
          articles.addAll(articlesData
              .map((articleData) => Article(
            headline: articleData['headline'],
            timeAgo: articleData['time_ago'],
            thumbnail: articleData['thumbnail'],
            link: articleData['link'],
          ))
              .toList());
          currentPage++;
        });
      } else {
        // If articlesData is empty, it means there are no more pages to fetch
        // Set hasMorePages to false to stop fetching more pages
        setState(() {
          hasMorePages = false;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: articles.isEmpty
          ? Center(child: isLoading ? CircularProgressIndicator() : Text("No articles available"))
          : ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + (hasMorePages ? 1 : 0), // Adjusted to show loading indicator only if there are more pages
        itemBuilder: (context, index) {
          if (index == articles.length) {
            // Display a loading indicator at the bottom when reaching the end of the list
            return Container(
              padding: EdgeInsets.all(16),
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }

          final article = articles[index];
          return GestureDetector(
              onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NewsContentScreen(url: article.link),
              ),
            );
          },
          child: Card(
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(15),
                bottom: Radius.circular(15),
              ),
            ),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                  child: Image.network(
                    article.thumbnail,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.headline,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        article.timeAgo,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
