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
    // 1. مراقبة حالة القائمة للتعامل مع التحميل والخطأ
    final tasbihListAsync = ref.watch(tasbihListProvider);

    // 2. ✨ استهلاك الذكر النشط الجاهز من الـ provider الجديد
    // لم يعد هناك أي منطق لحساب الذكر هنا في الواجهة
    final activeTasbih = ref.watch(activeTasbihProvider);

    return Scaffold(
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (tasbihList) {
          return SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: context.screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const TasbihHeader(),
                  ActiveTasbihView(activeTasbih: activeTasbih),
                  TasbihCounterButton(tasbihList: tasbihList),
                  const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
