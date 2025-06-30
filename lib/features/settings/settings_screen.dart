// lib/features/settings/settings_screen.dart
import 'package:azkari/core/providers/settings_provider.dart';
import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        padding: EdgeInsets.all(context.responsiveSize(16.0)),
        children: [
          _buildSectionTitle('المظهر', theme, context),
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
          _buildSectionTitle('حجم الخط', theme, context),
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
          // ✨ [جديد] قسم الإشعارات
          SizedBox(height: context.responsiveSize(24)),
          _buildSectionTitle('التنبيهات', theme, context),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تذكير أذكار الصباح'),
                  subtitle: const Text('يومياً الساعة 8:00 صباحاً'),
                  value: settings.morningNotificationEnabled,
                  onChanged: (bool value) {
                    settingsNotifier.updateMorningNotification(value);
                  },
                ),
                SwitchListTile(
                  title: const Text('تذكير أذكار المساء'),
                  subtitle: const Text('يومياً الساعة 5:30 مساءً'),
                  value: settings.eveningNotificationEnabled,
                  onChanged: (bool value) {
                    settingsNotifier.updateEveningNotification(value);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, ThemeData theme, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.responsiveSize(8.0)),
      child: Text(
        title,
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: context.responsiveSize(16),
        ),
      ),
    );
  }
}
