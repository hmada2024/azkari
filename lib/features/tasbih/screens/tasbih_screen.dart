// lib/features/tasbih/screens/tasbih_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/tasbih/providers/tasbih_provider.dart';
import 'package:azkari/features/tasbih/widgets/active_tasbih_view.dart';
import 'package:azkari/features/tasbih/widgets/completed_goals_view.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_counter_button.dart';
import 'package:azkari/features/tasbih/widgets/tasbih_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TasbihScreen extends ConsumerWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihListAsync = ref.watch(tasbihListProvider);

    return Scaffold(
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (tasbihList) {
          final activeTasbihAsync = ref.watch(activeTasbihProvider);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                    activeTasbihAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('خطأ: $err')),
                      data: (loadedActiveTasbih) {
                        return ActiveTasbihView(
                            activeTasbih: loadedActiveTasbih);
                      },
                    ),
                    SizedBox(height: context.screenHeight * 0.04),
                    TasbihCounterButton(tasbihList: tasbihList),
                    SizedBox(height: context.screenHeight * 0.03),

                    // [التعديل] استبدال القائمة المزدحمة بمنطقة الإنجازات النظيفة
                    const CompletedGoalsView(),
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
