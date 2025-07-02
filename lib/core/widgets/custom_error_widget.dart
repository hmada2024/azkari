// lib/core/widgets/custom_error_widget.dart
import 'package:azkari/core/utils/size_config.dart';
import 'package:azkari/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  const CustomErrorWidget({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: context.responsiveSize(60),
              color: theme.colorScheme.error,
            ),
            SizedBox(height: context.responsiveSize(16)),
            Text(
              'حدث خطأ ما',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.responsiveSize(8)),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: context.responsiveSize(24)),
              PrimaryButton(
                onPressed: onRetry!,
                text: 'إعادة المحاولة',
                icon: Icons.refresh_rounded,
              )
            ],
          ],
        ),
      ),
    );
  }
}
