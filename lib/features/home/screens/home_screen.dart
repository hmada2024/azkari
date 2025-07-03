// lib/features/home/screens/home_screen.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/app_logo.dart';
import 'package:azkari/core/widgets/custom_error_widget.dart';
import 'package:azkari/features/azkar_list/providers/azkar_list_providers.dart';
import 'package:azkari/features/home/providers/home_providers.dart';
import 'package:azkari/features/home/widgets/home_category_card.dart';
import 'package:azkari/features/settings/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final currentTimePeriod = ref.watch(timeOfDayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 32),
            const SizedBox(width: 12),
            Text(
              'أذكاري',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ],
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
              horizontal: context.screenWidth * 0.05,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final bool isHighlighted = (category == "أذكار الصباح" &&
                      currentTimePeriod == TimeOfDayPeriod.morning) ||
                  (category == "أذكار المساء" &&
                      currentTimePeriod == TimeOfDayPeriod.evening);

              return HomeCategoryCard(
                category: category,
                isHighlighted: isHighlighted,
              );
            },
          );
        },
      ),
    );
  }
}
