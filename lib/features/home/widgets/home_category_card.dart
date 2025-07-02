// lib/features/home/widgets/home_category_card.dart
import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/azkar_list/screens/azkar_screen.dart';
import 'package:flutter/material.dart';

class HomeCategoryCard extends StatelessWidget {
  final String category;
  const HomeCategoryCard({
    super.key,
    required this.category,
  });
  static const Map<String, IconData> _categoryIcons = {
    "أذكار الصباح": Icons.wb_sunny_outlined,
    "أذكار المساء": Icons.nightlight_round,
    "أذكار بعد السلام من الصلاة المفروضة": Icons.mosque_outlined,
    "أذكار النوم": Icons.bedtime_outlined,
    "أذكار الاستيقاظ من النوم": Icons.alarm,
    "أدعية قرآنية": Icons.menu_book_outlined,
    "أدعية نبوية": Icons.mosque,
  };
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final icon = _categoryIcons[category] ?? Icons.list_alt_rounded;
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: context.responsiveSize(6),
      ),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.blueGrey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
            padding: EdgeInsets.symmetric(
              horizontal: context.responsiveSize(16),
              vertical: context.responsiveSize(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.responsiveSize(12)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.primary,
                    size: context.responsiveSize(22),
                  ),
                ),
                SizedBox(width: context.responsiveSize(16)),
                Expanded(
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: context.responsiveSize(16),
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: context.responsiveSize(15),
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
