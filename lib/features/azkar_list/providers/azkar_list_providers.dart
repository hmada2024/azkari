// lib/features/azkar_list/providers/azkar_list_providers.dart
import 'package:azkari/core/providers/data_providers.dart';
import 'package:azkari/data/models/azkar_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'azkar_card_provider.dart';
final azkarByCategoryProvider =
    FutureProvider.family<List<AzkarModel>, String>((ref, category) async {
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getAzkarByCategory(category);
});
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repository = await ref.watch(azkarRepositoryProvider.future);
  return repository.getCategories();
});