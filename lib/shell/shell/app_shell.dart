// lib/shell/shell/app_shell.dart
import 'package:azkari/core/widgets/app_background.dart';
import 'package:azkari/features/home/screens/home_screen.dart';
import 'package:azkari/features/prayer_times/screens/prayer_times_screen.dart';
import 'package:azkari/features/progress/screens/progress_screen.dart';
import 'package:azkari/features/tasbih/screens/tasbih_screen.dart';
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
    PrayerTimesScreen(),
    ProgressScreen(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
              key: Key('bottom_nav_prayer'),
              icon: Icon(Icons.mosque_outlined),
              activeIcon: Icon(Icons.mosque),
              label: 'الصلاة',
            ),
            BottomNavigationBarItem(
              key: Key('bottom_nav_progress'),
              icon: Icon(Icons.assessment_outlined),
              activeIcon: Icon(Icons.assessment),
              label: 'تقدمي',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          elevation: theme.bottomNavigationBarTheme.elevation,
        ),
      ),
    );
  }
}
