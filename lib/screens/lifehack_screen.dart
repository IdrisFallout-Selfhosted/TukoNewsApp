import 'package:flutter/material.dart';
import 'package:tukonewsapp/models/article.dart';
import 'package:tukonewsapp/services/api_service.dart';

class LifehacksScreen extends StatefulWidget {
  @override
  _LifehacksScreenState createState() => _LifehacksScreenState();
}

class _LifehacksScreenState extends State<LifehacksScreen> {
  final String factsApiUrl = 'https://tuko.waithakasam.tech/facts-lifehacks/';
  final String celebrityBiographiesApiUrl = 'https://tuko.waithakasam.tech/celebrity-biographies/';
  final String messagesApiUrl = 'https://tuko.waithakasam.tech/messages-quotes/';
  final String guidesApiUrl = 'https://tuko.waithakasam.tech/guides/';
  final String tvAndMoviesApiUrl = 'https://tuko.waithakasam.tech/tv-movies/';
  final String studyApiUrl = 'https://tuko.waithakasam.tech/study/';
  final String fashionAndStyleApiUrl = 'https://tuko.waithakasam.tech/fashion-style/';
  final String musicAndSingersApiUrl = 'https://tuko.waithakasam.tech/music-singers/';
  final String gamingApiUrl = 'https://tuko.waithakasam.tech/gaming/';

  int currentPage = 1;
  List<Article> currentArticles = [];
  bool isLoading = false;
  bool hasMorePages = true;
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  bool shouldLoadLifehacksData = true;

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

      // Check if it's the Facts and Lifehacks subsection and should load data
      if (_currentIndex == 0 && !shouldLoadLifehacksData) {
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
            shouldLoadLifehacksData = false;
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
        return factsApiUrl;
      case 1:
        return celebrityBiographiesApiUrl;
      case 2:
        return messagesApiUrl;
      case 3:
        return guidesApiUrl;
      case 4:
        return tvAndMoviesApiUrl;
      case 5:
        return studyApiUrl;
      case 6:
        return fashionAndStyleApiUrl;
      case 7:
        return musicAndSingersApiUrl;
      case 8:
        return gamingApiUrl;
      default:
        return factsApiUrl;
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
                return Card(
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
                );
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
            shouldLoadLifehacksData = true; // Reset shouldLoadLifehacksData to true when switching tabs
          });
          fetchDataForCurrentTab();
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check),
            label: 'Facts and Lifehacks',
            backgroundColor: _currentIndex == 0 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Celebrity Biographies',
            backgroundColor: _currentIndex == 1 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'Messages - Wishes - Quotes',
            backgroundColor: _currentIndex == 2 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Guides',
            backgroundColor: _currentIndex == 3 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'TV and Movies',
            backgroundColor: _currentIndex == 4 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Study',
            backgroundColor: _currentIndex == 5 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Fashion and Style',
            backgroundColor: _currentIndex == 6 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music and Singers',
            backgroundColor: _currentIndex == 7 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Gaming',
            backgroundColor: _currentIndex == 8 ? Color(0xFF000000) : null,
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}

