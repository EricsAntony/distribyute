import 'package:distribution/pages/profile_page.dart';
import 'package:distribution/pages/welcomePage.dart';
import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    WelcomePage(), // New Home Page
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      bottomNavigationBar: MyBottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages[_selectedIndex],
    );
  }

  //Methods
  //for change the selected index when new tab is selected
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
