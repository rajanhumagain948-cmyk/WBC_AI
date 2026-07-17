import 'package:flutter/material.dart';
import 'main.dart';
import 'teachers_screen.dart';
import 'school_info_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    TeachersScreen(),
    SchoolInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: wbcGreen,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'AIチャット',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            label: '先生紹介',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            label: '学校情報',
          ),
        ],
      ),
    );
  }
}