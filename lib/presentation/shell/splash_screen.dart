// lib/presentation/shell/splash_screen.dart
import 'dart:math';
import 'package:azkari/data/repositories/app_shell.dart';
import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  // [تحسين] ✨: قائمة من الرسائل الملهمة
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [تحسين] ✨: اختيار رسالة عشوائية في كل مرة يتم بناء الشاشة
    final randomMessage =
        _inspirationalMessages[Random().nextInt(_inspirationalMessages.length)];

    ref.listen<AsyncValue<List<String>>>(categoriesProvider, (previous, next) {
      next.whenData((data) {
        if (data.isNotEmpty) {
          // نضيف تأخير بسيط جداً (500 ميلي ثانية) ليشعر المستخدم أنه قرأ الرسالة
          // قبل أن تختفي الشاشة فجأة. هذا يحسن التجربة.
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (context.mounted) {
              // هنا استخدام mounted آمن لأننا داخل Future.delayed
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AppShell()),
              );
            }
          });
        }
      });
    });

    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // يمكنك وضع شعار التطبيق هنا فوق المؤشر إذا أردت
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                randomMessage, // [تحسين] ✨: عرض الرسالة الملهمة العشوائية
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontFamily: 'Amiri', // خط Amiri يبدو رائعاً مع هذه الجمل
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
