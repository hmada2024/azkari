// lib/core/constants/app_constants.dart
// ✨ [إضافة جديدة]: ملف مركزي للثوابت (Constants).
// تجميع الثوابت مثل مفاتيح SharedPreferences في مكان واحد يمنع الأخطاء المطبعية،
// ويسهل التعديل عليها مستقبلاً، ويجعل الكود أكثر نظافة وقابلية للقراءة.

class AppConstants {
  // مفاتيح SharedPreferences للسبحة
  static const String tasbihCounterKey = 'tasbih_counter';
  static const String activeTasbihIdKey = 'active_tasbih_id';
  static const String lastResetDateKey = 'last_reset_date';
  static const String usedTasbihIdsKey = 'used_tasbih_ids_today';
  
  // مفاتيح SharedPreferences للمفضلة
  static const String favoritesKey = 'favorite_adhkar_ids';

  // مفاتيح SharedPreferences للإعدادات
  static const String themeKey = 'theme_mode';
  static const String fontScaleKey = 'font_scale';
}