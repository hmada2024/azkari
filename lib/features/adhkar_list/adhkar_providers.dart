import 'package:azkari/data/models/adhkar_model.dart';
import 'package:azkari/data/repositories/adhkar_repository.dart';
import 'package:azkari/data/services/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart'; // ✨ استيراد جديد

// Provider 0: يوفر اتصال قاعدة البيانات كـ Future (الأفضل)
// سيتم استدعاؤه مرة واحدة تلقائيًا عند الحاجة إليه لأول مرة.
final databaseProvider = FutureProvider<Database>((ref) async {
  // استخدام الـ Helper لتهيئة قاعدة البيانات
  return await DatabaseHelper.instance.database;
});

// Provider 1: يوفر نسخة واحدة من المستودع (Repository)
// يعتمد الآن على provider قاعدة البيانات الجديد
final adhkarRepositoryProvider = Provider<AdhkarRepository>((ref) {
  // لا نحتاج لمشاهدة الـ Future بالكامل، فقط الـ Helper
  // الـ Helper داخليًا سيضمن أن قاعدة البيانات مهيأة
  return AdhkarRepository(DatabaseHelper.instance);
});

// Provider 2: يجلب الأذكار حسب التصنيف (لا تغيير هنا)
final adhkarByCategoryProvider =
    FutureProvider.family<List<AdhkarModel>, String>((ref, category) async {
  // عند مشاهدة هذا الـ provider، سيتم تشغيل سلسلة الاعتماديات
  // databaseProvider > adhkarRepositoryProvider > getAdhkarByCategory
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getAdhkarByCategory(category);
});

// Provider 3: يجلب قائمة الفئات (لا تغيير هنا)
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(adhkarRepositoryProvider);
  return repository.getCategories();
});
