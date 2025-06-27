// lib/presentation/shell/splash_screen.dart
import 'dart:math';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/presentation/shell/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const List<String> _inspirationalMessages = [
    "ألا بذكر الله تطمئن القلوب.",
    "اذكارك حياتك وقد تكون سبب نجاتك فلا تتركها.",
    "اذكر الله في رخائك، يذكرك في شدتك.",
    "ذكر الله يورث القلب حياة ونوراً.",
    "سبحان الله وبحمده، عدد خلقه، ورضا نفسه، وزنة عرشه، ومداد كلماته.",
    "الذاكرون الله كثيراً والذاكرات، أعد الله لهم مغفرة وأجراً عظيماً.",
    "اجعل لسانك رطباً بذكر الله.",
    "أذكارك حصنك المنيع، فلا تهجره.",
  ];

  void _navigateToHome(BuildContext context) {
    // استخدمنا مدة تأخير ثابتة لضمان بقاء الشاشة قليلاً حتى لو كانت البيانات سريعة التحميل.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppShell()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomMessage =
        _inspirationalMessages[Random().nextInt(_inspirationalMessages.length)];

    final categoriesAsync = ref.watch(categoriesProvider);

    categoriesAsync.whenOrNull(
      data: (_) {
        Future.microtask(() => _navigateToHome(context));
      },
      error: (error, stack) {
        Future.microtask(() {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حدث خطأ في تهيئة التطبيق: $error'),
                backgroundColor: Colors.red,
              ),
            );
            _navigateToHome(context);
          }
        });
      },
    );

    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                randomMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontFamily: 'Amiri',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
