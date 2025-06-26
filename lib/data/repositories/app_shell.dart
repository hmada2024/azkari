// lib/data/repositories/app_shell.dart
import 'package:azkari/features/tasbih/tasbih_screen.dart'; 
import 'package:azkari/features/favorites/favorites_screen.dart';
import 'package:azkari/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // 2. أضف شاشة السبحة إلى قائمة الشاشات
  // الترتيب المقترح: الرئيسية، السبحة، المفضلة
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TasbihScreen(), // <-- الإضافة هنا
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        // 3. أضف أيقونة السبحة إلى شريط التنقل
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            // يمكنك اختيار أيقونة أخرى تراها مناسبة
            icon: Icon(Icons.fingerprint),
            activeIcon: Icon(Icons.fingerprint),
            label: 'السبحة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border_outlined),
            activeIcon: Icon(Icons.star),
            label: 'المفضلة',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}