// lib/features/settings/screens/settings_screen.dart
import 'dart:io';
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/app_background.dart';
import 'package:azkari/features/settings/providers/settings_provider.dart';
import 'package:azkari/features/settings/widgets/section_title.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);
    final bool notificationsSupported =
        !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                    groupValue:
                        ref.watch(settingsProvider.select((s) => s.themeMode)),
                    onChanged: (value) => settingsNotifier.updateTheme(value!),
                    activeColor: theme.colorScheme.secondary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('داكن'),
                    value: ThemeMode.dark,
                    groupValue:
                        ref.watch(settingsProvider.select((s) => s.themeMode)),
                    onChanged: (value) => settingsNotifier.updateTheme(value!),
                    activeColor: theme.colorScheme.secondary,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('حسب النظام'),
                    value: ThemeMode.system,
                    groupValue:
                        ref.watch(settingsProvider.select((s) => s.themeMode)),
                    onChanged: (value) => settingsNotifier.updateTheme(value!),
                    activeColor: theme.colorScheme.secondary,
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
                    Consumer(builder: (context, ref, _) {
                      final fontScale = ref
                          .watch(settingsProvider.select((s) => s.fontScale));
                      return Text(
                        'سبحان الله وبحمده، سبحان الله العظيم',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: context.responsiveSize(20) * fontScale),
                      );
                    }),
                    SizedBox(height: context.responsiveSize(16)),
                    Consumer(builder: (context, ref, _) {
                      final fontScale = ref
                          .watch(settingsProvider.select((s) => s.fontScale));
                      return Slider(
                        value: fontScale,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: '${(fontScale * 100).toStringAsFixed(0)}%',
                        onChanged: (value) =>
                            settingsNotifier.updateFontScale(value),
                        activeColor: theme.colorScheme.secondary,
                        inactiveColor:
                            theme.colorScheme.secondary.withOpacity(0.3),
                      );
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: context.responsiveSize(24)),
            const SectionTitle(title: 'التنبيهات'),
            Card(
              child: Column(
                children: [
                  Consumer(builder: (context, ref, _) {
                    final morningEnabled = ref.watch(settingsProvider
                        .select((s) => s.morningNotificationEnabled));
                    return SwitchListTile(
                      title: const Text('تذكير أذكار الصباح'),
                      subtitle: Text(notificationsSupported
                          ? 'يومياً الساعة 8:00 صباحاً'
                          : 'غير مدعوم على هذه المنصة'),
                      value: morningEnabled,
                      onChanged: notificationsSupported
                          ? (bool value) {
                              settingsNotifier.updateMorningNotification(value);
                            }
                          : null,
                      activeColor: theme.colorScheme.secondary,
                    );
                  }),
                  Consumer(builder: (context, ref, _) {
                    final eveningEnabled = ref.watch(settingsProvider
                        .select((s) => s.eveningNotificationEnabled));
                    return SwitchListTile(
                      title: const Text('تذكير أذكار المساء'),
                      subtitle: Text(notificationsSupported
                          ? 'يومياً الساعة 5:30 مساءً'
                          : 'غير مدعوم على هذه المنصة'),
                      value: eveningEnabled,
                      onChanged: notificationsSupported
                          ? (bool value) {
                              settingsNotifier.updateEveningNotification(value);
                            }
                          : null,
                      activeColor: theme.colorScheme.secondary,
                    );
                  }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
