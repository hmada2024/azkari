// lib/main.dart
import 'dart:io';
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/presentation/shell/splash_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart'; // ✨ 1. استيراد الحزمة الجديدة

// ✨ 2. جعل الدالة main غير متزامنة (async)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✨ 3. إضافة هذا الجزء بالكامل للتحكم بالنافذة على سطح المكتب
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // التأكد من تهيئة مدير النوافذ
    await windowManager.ensureInitialized();

    // إعدادات النافذة التي نريدها
    WindowOptions windowOptions = const WindowOptions(
      size: Size(250, 500), // حجم ابتدائي يشبه الهاتف
      minimumSize: Size(200, 400), // أصغر حجم يمكن للمستخدم تصغير النافذة إليه
      center: true, // جعل النافذة تظهر في منتصف الشاشة
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    // تطبيق الإعدادات وإظهار النافذة
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    // تهيئة قاعدة البيانات لسطح المكتب
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // نهاية الجزء المضاف
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    // ... باقي الكود يبقى كما هو بدون تغيير
    return MaterialApp(
      title: 'أذكاري',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
      locale: const Locale('ar', 'SA'),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 1.0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
        cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        primaryColor: Colors.tealAccent,
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 1.0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.tealAccent),
          titleTextStyle: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent.shade100),
        ),
        cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15))),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        dividerColor: Colors.white24,
      ),
      themeMode: settings.themeMode,
      home: const SplashScreen(),
    );
  }
}
