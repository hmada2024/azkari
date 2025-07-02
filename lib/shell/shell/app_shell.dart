// lib/presentation/shell/app_shell.dart
import 'package:azkari/features/progress/screens/progress_screen.dart'; 
import 'package:azkari/features/tasbih/screens/tasbih_screen.dart';
import 'package:azkari/features/home/home_screen.dart';
import 'package:flutter/material.dart';
class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}
class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    TasbihScreen(),
    ProgressScreen(), 
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
          BottomNavigationBarItem(
            key: Key('bottom_nav_progress'),
            icon: Icon(Icons.assessment_outlined), 
            activeIcon: Icon(Icons.assessment),
            label: 'تقدمي', 
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