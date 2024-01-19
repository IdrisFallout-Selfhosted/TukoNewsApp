import 'package:flutter/material.dart';
import 'package:tukonewsapp/models/article.dart';
import 'package:tukonewsapp/services/api_service.dart';
import 'package:tukonewsapp/screens/news_content_screen.dart';

class EntertainmentScreen extends StatefulWidget {
  @override
  _EntertainmentScreenState createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  final String entertainmentApiUrl = 'https://tuko.waithakasam.tech/entertainment/';
  final String celebritiesApiUrl = 'https://tuko.waithakasam.tech/entertainment/celebrities/';
  final String moviesApiUrl = 'https://tuko.waithakasam.tech/entertainment/movies/';
  final String musicApiUrl = 'https://tuko.waithakasam.tech/entertainment/music/';
  final String tvShowsApiUrl = 'https://tuko.waithakasam.tech/entertainment/tv-shows/';

  int currentPage = 1;
  List<Article> currentArticles = [];
  bool isLoading = false;
  bool hasMorePages = true;
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  bool shouldLoadEntertainmentData = true;

  @override
  void initState() {
    super.initState();
    fetchDataForCurrentTab();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchDataForCurrentTab();
      }
    });
  }

  Future<void> fetchDataForCurrentTab() async {
    if (isLoading || !hasMorePages) return;

    setState(() {
      isLoading = true;
    });

    try {
      final String currentApiUrl = getCurrentApiUrl();

      // Check if it's the Entertainment subsection and should load data
      if (_currentIndex == 0 && !shouldLoadEntertainmentData) {
        setState(() {
          hasMorePages = false;
        });
        return;
      }

      final Map<String, dynamic> data = await makeGETRequest('$currentApiUrl$currentPage');

      final List<dynamic> currentArticlesData = data['data'];

      if (currentArticlesData.isNotEmpty) {
        setState(() {
          currentArticles.addAll(currentArticlesData
              .map((articleData) => Article(
            headline: articleData['headline'],
            timeAgo: articleData['time_ago'],
            thumbnail: articleData['thumbnail'],
            link: articleData['link'],
          ))
              .toList());
          currentPage++;
          if (_currentIndex == 0) {
            shouldLoadEntertainmentData = false;
          }
        });
      } else {
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

  String getCurrentApiUrl() {
    switch (_currentIndex) {
      case 0:
        return entertainmentApiUrl;
      case 1:
        return celebritiesApiUrl;
      case 2:
        return moviesApiUrl;
      case 3:
        return musicApiUrl;
      case 4:
        return tvShowsApiUrl;
      default:
        return entertainmentApiUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: currentArticles.isEmpty
                ? Center(
              child: isLoading ? CircularProgressIndicator() : Text("No articles available"),
            )
                : ListView.builder(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: currentArticles.length + (hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == currentArticles.length) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: isLoading ? CircularProgressIndicator() : null,
                  );
                }

                final article = currentArticles[index];
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
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            currentArticles.clear(); // Clear the current articles when switching tabs
            currentPage = 1; // Reset page to 1 when switching tabs
            hasMorePages = true; // Reset hasMorePages to true when switching tabs
            shouldLoadEntertainmentData = true; // Reset shouldLoadEntertainmentData to true when switching tabs
          });
          fetchDataForCurrentTab();
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Entertainment',
            backgroundColor: _currentIndex == 0 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Celebrities',
            backgroundColor: _currentIndex == 1 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter),
            label: 'Movies',
            backgroundColor: _currentIndex == 2 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
            backgroundColor: _currentIndex == 3 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'TV Shows',
            backgroundColor: _currentIndex == 4 ? Color(0xFF000000) : null,
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}
