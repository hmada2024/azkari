// lib/features/home/home_screen.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/azkar_list/screens/azkar_screen.dart';
import 'package:azkari/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    Theme.of(context);

    final Map<String, IconData> categoryIcons = {
      "أذكار الصباح": Icons.wb_sunny_outlined,
      "أذكار المساء": Icons.nightlight_round,
      "أذكار بعد السلام من الصلاة المفروضة": Icons.mosque_outlined,
      "أذكار النوم": Icons.bedtime_outlined,
      "أذكار الاستيقاظ من النوم": Icons.alarm,
      "أدعية قرآنية": Icons.menu_book_outlined,
      "أدعية نبوية": Icons.mosque,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أذكاري',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: categoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => CustomErrorWidget(
          errorMessage: 'فشل تحميل فئات الأذكار.',
          onRetry: () => ref.invalidate(categoriesProvider),
        ),
        data: (categories) {
          return ListView.builder(
            padding: EdgeInsets.symmetric(
                vertical: context.responsiveSize(8.0),
                horizontal:
                    context.responsiveSize(12.0)), // تعديل بسيط للهامش العام
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon = categoryIcons[category] ?? Icons.list_alt_rounded;

              return Card(
                margin: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(5),
                  horizontal: context.screenWidth * 0.05,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                clipBehavior:
                    Clip.antiAlias, // لضمان أن تأثير الضغط يتبع الحواف الدائرية
                child: ListTile(
                  // ListTile هو الويدجت المثالي لهذا التصميم
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AzkarScreen(category: category),
                      ),
                    );
                  },
                  // التحكم في الحشوات الداخلية لجعل البطاقة مدمجة أكثر
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(12),
                    vertical: context
                        .responsiveSize(4), // تقليل الحشوة العمودية بشكل كبير
                  ),
                  leading: CircleAvatar(
                    // تصغير حجم الدائرة والأيقونة بداخلها
                    radius: context.responsiveSize(20),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(icon,
                        color: AppColors.primary,
                        size: context.responsiveSize(20)),
                  ),
                  title: Text(
                    category,
                    style: TextStyle(
                      fontSize: context.responsiveSize(15), // تصغير الخط قليلاً
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: context.responsiveSize(15),
                      color: Colors.grey.shade400),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
