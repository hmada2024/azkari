// lib/presentation/shell/splash_screen.dart
import 'package:azkari/data/repositories/app_shell.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<List<String>>>(categoriesProvider, (previous, next) {
      next.whenData((data) {
        if (data.isNotEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AppShell()),
          );
        }
      });
    });

    return const Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              "جاري تهيئة البيانات...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
