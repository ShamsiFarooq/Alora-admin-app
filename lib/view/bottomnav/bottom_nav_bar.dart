import 'package:alora_admin/view/chat/admin_chat.dart';
import 'package:alora_admin/style/constant.dart';
import 'package:flutter/material.dart';
import 'package:alora_admin/view/requirement/requirement.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndexNavBar = 0;
  final screens = [
    OrderListScreen(),
    AdminChatScreen(),
    // RevenueScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndexNavBar],
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
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
          // BottomNavigationBarItem(
          //   backgroundColor: color2,
          //   // ignore: unnecessary_const
          //   icon: Icon(Icons.reviews),
          //   label: 'revenue',
          // ),
        ],
      ),
    );
  }
}
