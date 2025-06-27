// lib/features/tasbih/tasbih_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/active_tasbih_view.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihListAsync = ref.watch(tasbihListProvider);
    final activeTasbih = ref.watch(activeTasbihProvider);

    return Scaffold(
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (tasbihList) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                // [تعديل التجاوب] استخدام نسبة مئوية من عرض الشاشة
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.05,
                  vertical: context.responsiveSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TasbihHeader(),

                    // [تعديل التجاوب] استخدام نسبة مئوية من ارتفاع الشاشة
                    SizedBox(height: context.screenHeight * 0.06),

                    ActiveTasbihView(activeTasbih: activeTasbih),

                    // [تعديل التجاوب] استخدام نسبة مئوية من ارتفاع الشاشة
                    SizedBox(height: context.screenHeight * 0.06),

                    TasbihCounterButton(tasbihList: tasbihList),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
