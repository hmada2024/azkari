// lib/features/tasbih/tasbih_screen.dart

import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/data/models/tasbih_model.dart';
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
    SizeConfig().init(context);
    final tasbihListAsync = ref.watch(tasbihListProvider);

    return Scaffold(
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (tasbihList) {
          // منطق تحديد الذكر النشط يبقى هنا لأنه "حالة" الشاشة
          final activeTasbihId =
              ref.watch(tasbihStateProvider.select((s) => s.activeTasbihId));
          final activeTasbih = tasbihList.firstWhere(
            (t) => t.id == activeTasbihId,
            orElse: () => tasbihList.isNotEmpty
                ? tasbihList.first
                : TasbihModel(
                    id: -1,
                    text: 'اختر ذكرًا للبدء من القائمة',
                    sortOrder: 0,
                    isDeletable: false,
                  ),
          );

          // ✨ انظر كم أصبحت دالة البناء بسيطة ونظيفة! ✨
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. الرأس
                  const TasbihHeader(),

                  // 2. عرض الذكر
                  ActiveTasbihView(activeTasbih: activeTasbih),

                  // 3. زر العداد
                  TasbihCounterButton(tasbihList: tasbihList),

                  // عنصر فارغ لتوزيع المسافات بشكل أفضل
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
