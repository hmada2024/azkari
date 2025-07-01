// lib/features/home/widgets/home_category_card.dart

import 'package:azkari/core/constants/app_colors.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/azkar_list/screens/azkar_screen.dart';
import 'package:flutter/material.dart';

/// ويدجت يمثل بطاقة تصنيف واحدة في الشاشة الرئيسية.
/// مسؤول عن عرض الأيقونة والنص والتفاعل (الانتقال إلى شاشة الأذكار).
class HomeCategoryCard extends StatelessWidget {
  final String category;

  const HomeCategoryCard({
    super.key,
    required this.category,
  });

  // تم نقل هذا المنطق إلى هنا لأنه خاص بعرض هذه البطاقة.
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
    final icon = _categoryIcons[category] ?? Icons.list_alt_rounded;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: context.responsiveSize(5),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AzkarScreen(category: category),
            ),
          );
        },
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(12),
          vertical: context.responsiveSize(4),
        ),
        leading: CircleAvatar(
          radius: context.responsiveSize(20),
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: context.responsiveSize(20),
          ),
        ),
        title: Text(
          category,
          style: TextStyle(
            fontSize: context.responsiveSize(15),
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: context.responsiveSize(15),
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
