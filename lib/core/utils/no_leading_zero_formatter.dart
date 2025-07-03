// lib/core/utils/no_leading_zero_formatter.dart
import 'package:flutter/services.dart';

class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('0') && newValue.text.length > 1) {
      return TextEditingValue(
        text: newValue.text.substring(1),
        selection: TextSelection.collapsed(offset: newValue.selection.end - 1),
      );
    }
    return newValue;
  }
}
