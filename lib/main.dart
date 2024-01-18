import 'package:flutter/material.dart';
import 'screens/editorial_screen.dart';
import 'screens/home_screen.dart';
import 'screens/climate_screen.dart';
import 'screens/politics_screen.dart';
import 'screens/kenya_screen.dart';
import 'screens/world_screen.dart';
import 'screens/entertainment_screen.dart';
import 'screens/people_screen.dart';
import 'screens/business_screen.dart';
import 'screens/sports_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawer Example',
      theme: ThemeData(
        primaryColor: Color(0xFFC21516),
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<String> drawerItems = [
    'Home',
    'Climate',
    'Politics',
    'Kenya',
    'World',
    'Entertainment',
    'People',
    'Business',
    'Sports',
    'Editorial'
  ];

  List<Widget> screens = [
    HomeScreen(),
    ClimateScreen(),
    PoliticsScreen(),
    KenyaScreen(),
    WorldScreen(),
    EntertainmentScreen(),
    PeopleScreen(),
    BusinessScreen(),
    SportsScreen(),
    EditorialScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drawerItems[_currentIndex]),
        backgroundColor: Color(0xFFC21516), // Set the background color for the entire AppBar
      ),
      drawer: MyDrawer(
        drawerItems: drawerItems,
        onItemSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pop(context);
        },
      ),
      body: screens[_currentIndex],
    );
  }
}

class MyDrawer extends StatelessWidget {
  final List<String> drawerItems;
  final Function(int) onItemSelected;

  MyDrawer({required this.drawerItems, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFC21516),
            ),
            child: Text(
              'Tuko News',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          for (int i = 0; i < drawerItems.length; i++)
            ListTile(
              title: Text(drawerItems[i]),
              onTap: () => onItemSelected(i),
            ),
        ],
      ),
    );
  }
}
