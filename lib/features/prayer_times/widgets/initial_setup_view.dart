// lib/features/prayer_times/widgets/initial_setup_view.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/primary_button.dart';
import 'package:azkari/features/prayer_times/providers/prayer_times_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InitialSetupView extends ConsumerWidget {
  const InitialSetupView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mosque_outlined,
              size: context.responsiveSize(80),
              color: theme.primaryColor.withOpacity(0.6),
            ),
            SizedBox(height: context.responsiveSize(24)),
            Text(
              'مواقيت صلاتك، دائماً معك',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(12)),
            Text(
              'لحساب مواقيت الصلاة بدقة لموقعك، نحتاج إلى تحديد موقعك لمرة واحدة فقط. سيتم حفظ الإعدادات على جهازك ولن نحتاج إلى الإنترنت أو خدمة الموقع مرة أخرى.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(24)),
            PrimaryButton(
              onPressed: () {
                ref.read(prayerTimesProvider.notifier).setupAutomatic();
              },
              text: 'تحديد الموقع تلقائياً',
              icon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
