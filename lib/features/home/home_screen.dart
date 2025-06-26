import 'package:azkari/features/adhkar_list/adhkar_providers.dart';
import 'package:azkari/features/adhkar_list/adhkar_screen.dart';
import 'package:azkari/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    // ربط أسماء الفئات بأيقونات (مثال)
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
        title: const Text('أذكاري'),
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
        error: (error, stack) => Center(child: Text('حدث خطأ: $error')),
        data: (categories) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final icon = categoryIcons[category] ?? Icons.list_alt_rounded;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AdhkarScreen(category: category),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Icon(icon, color: theme.primaryColor, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
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