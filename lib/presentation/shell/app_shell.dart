// lib/presentation/shell/app_shell.dart
import 'package:azkari/features/progress/progress_screen.dart'; // ✨ 1. استيراد الشاشة الجديدة
import 'package:azkari/features/tasbih/tasbih_screen.dart';
// import 'package:azkari/features/favorites/favorites_screen.dart'; // ✨ 2. حذف استيراد المفضلة
import 'package:azkari/features/home/home_screen.dart';
import 'package:flutter/material.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  // ✨ 3. تحديث قائمة الواجهات
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TasbihScreen(),
    ProgressScreen(), // استبدال FavoritesScreen بـ ProgressScreen
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            key: Key('bottom_nav_home'),
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            key: Key('bottom_nav_tasbih'),
            icon: Icon(Icons.fingerprint),
            activeIcon: Icon(Icons.fingerprint),
            label: 'السبحة',
          ),
          // ✨ 4. تحديث العنصر الثالث بالكامل
          BottomNavigationBarItem(
            key: Key('bottom_nav_progress'),
            icon: Icon(Icons.assessment_outlined), // أيقونة جديدة ومناسبة
            activeIcon: Icon(Icons.assessment),
            label: 'تقدمي', // تسمية جديدة
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
