// lib/features/tasbih/tasbih_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/active_tasbih_view.dart';
import 'package:azkari/features/tasbih/widgets/daily_goals_view.dart';
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
                padding: EdgeInsets.symmetric(
                  horizontal: context.screenWidth * 0.05,
                  vertical: context.responsiveSize(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TasbihHeader(),

                    SizedBox(height: context.screenHeight * 0.04),

                    ActiveTasbihView(activeTasbih: activeTasbih),

                    SizedBox(height: context.screenHeight * 0.04),

                    TasbihCounterButton(tasbihList: tasbihList),

                    SizedBox(height: context.screenHeight * 0.04),

                    // ✨ [جديد] إضافة واجهة عرض الأهداف اليومية
                    const DailyGoalsView(),
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
