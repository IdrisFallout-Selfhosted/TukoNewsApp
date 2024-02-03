import 'package:flutter/material.dart';
import 'package:tukonewsapp/models/article.dart';
import 'package:tukonewsapp/services/api_service.dart';
import 'package:tukonewsapp/screens/news_content_screen.dart';

class BusinessScreen extends StatefulWidget {
  @override
  _BusinessScreenState createState() => _BusinessScreenState();
}

class _BusinessScreenState extends State<BusinessScreen> {
  final String businessApiUrl = 'https://tuko.waithakasam.com/business/';
  final String energyApiUrl = 'https://tuko.waithakasam.com/business/energy/';
  final String capitalMarketApiUrl = 'https://tuko.waithakasam.com/business/capital-market/';
  final String moneyApiUrl = 'https://tuko.waithakasam.com/business/money/';
  final String industryApiUrl = 'https://tuko.waithakasam.com/business/industry/';
  final String technologyApiUrl = 'https://tuko.waithakasam.com/business/technology/';

  int currentPage = 1;
  List<Article> currentArticles = [];
  bool isLoading = false;
  bool hasMorePages = true;
  ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;
  bool shouldLoadBusinessData = true;

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

      // Check if it's the Business subsection and should load data
      if (_currentIndex == 0 && !shouldLoadBusinessData) {
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
            shouldLoadBusinessData = false;
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
        return businessApiUrl;
      case 1:
        return energyApiUrl;
      case 2:
        return capitalMarketApiUrl;
      case 3:
        return moneyApiUrl;
      case 4:
        return industryApiUrl;
      case 5:
        return technologyApiUrl;
      default:
        return businessApiUrl;
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
            shouldLoadBusinessData = true; // Reset shouldLoadBusinessData to true when switching tabs
          });
          fetchDataForCurrentTab();
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Business',
            backgroundColor: _currentIndex == 0 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Energy',
            backgroundColor: _currentIndex == 1 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Capital Market',
            backgroundColor: _currentIndex == 2 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Money',
            backgroundColor: _currentIndex == 3 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: 'Industry',
            backgroundColor: _currentIndex == 4 ? Color(0xFF000000) : null,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: 'Technology',
            backgroundColor: _currentIndex == 5 ? Color(0xFF000000) : null,
          ),
        ],
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        backgroundColor: Colors.black,
      ),
    );
  }
}
