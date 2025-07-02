// lib/features/settings/widgets/section_title.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: context.responsiveSize(8.0),
        right: context.responsiveSize(4.0),
        left: context.responsiveSize(4.0),
      ),
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
