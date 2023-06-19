import 'package:alora_admin/screen/chat/admin_chat.dart';
import 'package:alora_admin/screen/requirement/requirement.dart';
import 'package:alora_admin/screen/revenue/revenue.dart';
import 'package:alora_admin/style/constant.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndexNavBar = 0;
  final screens = [RequirementScreen(), AdminChat(), RevenueScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndexNavBar],
      backgroundColor: color1,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndexNavBar,
        onTap: (index) => setState(() => currentIndexNavBar = index),
        iconSize: 40,
        selectedItemColor: color4,
        unselectedItemColor: color3,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            backgroundColor: color2,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: color2,
            icon: Icon(Icons.chat),
            label: 'chat',
          ),
          BottomNavigationBarItem(
            backgroundColor: color2,
            // ignore: unnecessary_const
            icon: Icon(Icons.reviews),
            label: 'revenue',
          ),
        ],
      ),
    );
  }
}
