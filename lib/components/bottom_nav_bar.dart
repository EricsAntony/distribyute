import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MyBottomNavBar extends StatefulWidget {
  final void Function(int)? onTabChange;

  MyBottomNavBar({Key? key, required this.onTabChange});

  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      child: GNav(
        color: Colors.grey[400],
        activeColor: Colors.indigoAccent[700],
        tabActiveBorder: Border.all(color: Colors.white),
        tabBackgroundColor: Colors.indigo,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBorderRadius: 24,
        gap: 8,
        selectedIndex: _selectedIndex,
        onTabChange: (index) {
          widget.onTabChange?.call(index);
          setState(() {
            _selectedIndex = index;
          });
        },
        tabs: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.account_circle, 'Profile', 1), // Add the More tab
        ],
      ),
    );
  }

  GButton _buildNavItem(IconData icon, String text, int index) {
    return GButton(
      icon: icon,
      text: text,
      textStyle: TextStyle(fontSize: 16, color: _selectedIndex == index ? Colors.indigoAccent[700] : Colors.grey[400]),
      iconColor: _selectedIndex == index ? Colors.indigoAccent[700] : Colors.grey[400],
      textColor: _selectedIndex == index ? Colors.indigoAccent[700] : Colors.grey[400],
      backgroundColor: _selectedIndex == index ? Colors.white : Colors.grey.shade100,
    );
  }
}
