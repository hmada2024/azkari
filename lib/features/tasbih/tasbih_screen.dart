import 'package:azkari/core/utils/size_config.dart'; // سيعمل الآن كـ extension
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
    final tasbihListAsync = ref.watch(tasbihListProvider);

    return Scaffold(
      body: tasbihListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('خطأ: $err')),
        data: (tasbihList) {
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

          return SafeArea(
            child: Padding(
              // [تحسين] ✨: استخدام الـ extension الجديد
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
