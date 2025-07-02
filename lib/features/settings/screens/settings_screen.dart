// lib/features/settings/screens/settings_screen.dart
import 'dart:io';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/features/settings/providers/settings_provider.dart';
import 'package:azkari/features/settings/widgets/section_title.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final bool notificationsSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: EdgeInsets.all(context.responsiveSize(16.0)),
        children: [
          const SectionTitle(title: 'المظهر'),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('فاتح'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (value) => settingsNotifier.updateTheme(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('داكن'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (value) => settingsNotifier.updateTheme(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('حسب النظام'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (value) => settingsNotifier.updateTheme(value!),
                ),
              ],
            ),
          ),
          SizedBox(height: context.responsiveSize(24)),
          const SectionTitle(title: 'حجم الخط'),
          Card(
            child: Padding(
              padding: EdgeInsets.all(context.responsiveSize(16.0)),
              child: Column(
                children: [
                  Text('سبحان الله وبحمده، سبحان الله العظيم',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize:
                              context.responsiveSize(20) * settings.fontScale)),
                  SizedBox(height: context.responsiveSize(16)),
                  Slider(
                    value: settings.fontScale,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    label: '${(settings.fontScale * 100).toStringAsFixed(0)}%',
                    onChanged: (value) =>
                        settingsNotifier.updateFontScale(value),
                    activeColor: theme.primaryColor,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.responsiveSize(24)),
          const SectionTitle(title: 'التنبيهات'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تذكير أذكار الصباح'),
                  subtitle: Text(notificationsSupported
                      ? 'يومياً الساعة 8:00 صباحاً'
                      : 'غير مدعوم على هذه المنصة'),
                  value: settings.morningNotificationEnabled,
                  onChanged: notificationsSupported
                      ? (bool value) {
                          settingsNotifier.updateMorningNotification(value);
                        }
                      : null,
                ),
                SwitchListTile(
                  title: const Text('تذكير أذكار المساء'),
                  subtitle: Text(notificationsSupported
                      ? 'يومياً الساعة 5:30 مساءً'
                      : 'غير مدعوم على هذه المنصة'),
                  value: settings.eveningNotificationEnabled,
                  onChanged: notificationsSupported
                      ? (bool value) {
                          settingsNotifier.updateEveningNotification(value);
                        }
                      : null,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}