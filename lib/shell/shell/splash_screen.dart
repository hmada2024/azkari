// lib/presentation/shell/splash_screen.dart
import 'dart:math';
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/shell/shell/app_shell.dart';
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

  // ✨ [تبسيط] دالة الانتقال أصبحت أبسط.
  void _navigateToHome(BuildContext context) {
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppShell()),
      );
    }
  }

  // ✨ [جديد] واجهة التحميل الموحدة.
  Widget _buildLoadingUI(BuildContext context, String randomMessage) {
    return Scaffold(
      backgroundColor: AppColors.primary,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final randomMessage =
        _inspirationalMessages[Random().nextInt(_inspirationalMessages.length)];

    final categoriesAsync = ref.watch(categoriesProvider);

    // ✨ [تعديل جذري] استخدام .when الكامل لمعالجة جميع الحالات (التحميل، الخطأ، البيانات).
    return categoriesAsync.when(
      loading: () => _buildLoadingUI(context, randomMessage),
      error: (error, stack) {
        // ✨ في حالة الخطأ، نعرض واجهة خطأ واضحة مع زر إعادة المحاولة.
        return Scaffold(
          body: CustomErrorWidget(
            errorMessage:
                'فشل تحميل البيانات الأساسية. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
        );
      },
      data: (_) {
        // ✨ عند نجاح تحميل البيانات، ننتقل للشاشة الرئيسية.
        // استخدام Future.microtask يضمن أن الانتقال يحدث بعد اكتمال بناء الإطار الحالي.
        Future.microtask(() => _navigateToHome(context));
        // نستمر في عرض واجهة التحميل أثناء الانتقال السلس.
        return _buildLoadingUI(context, randomMessage);
      },
    );
  }
}
