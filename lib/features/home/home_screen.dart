// lib/features/home/home_screen.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/azkar_providers.dart';
import 'package:azkari/features/azkar_list/azkar_screen.dart';
import 'package:azkari/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

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
                horizontal: context.responsiveSize(10.0)),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon = categoryIcons[category] ?? Icons.list_alt_rounded;
              return Container(
                margin: EdgeInsets.symmetric(
                  vertical: context.responsiveSize(6),
                  horizontal: context.screenWidth * 0.1,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(color: theme.dividerColor.withOpacity(0.5)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AzkarScreen(category: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(context.responsiveSize(16.0)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: context.responsiveSize(22),
                          backgroundColor: AppColors.accent.withOpacity(0.5),
                          child: Icon(icon,
                              color: AppColors.primary,
                              size: context.responsiveSize(22)),
                        ),
                        SizedBox(width: context.responsiveSize(16)),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: context.responsiveSize(16),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: context.responsiveSize(16),
                            color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
