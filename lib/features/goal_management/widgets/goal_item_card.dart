// lib/features/goal_management/widgets/goal_item_card.dart
import 'package:azkari/core/utils/no_leading_zero_formatter.dart';
import 'package:azkari/data/models/managed_goal_model.dart';
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalItemCard extends ConsumerStatefulWidget {
  final ManagedGoal item;
  const GoalItemCard({
    super.key,
    required this.item,
  });
  @override
  ConsumerState<GoalItemCard> createState() => _GoalItemCardState();
}

class _GoalItemCardState extends ConsumerState<GoalItemCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: (widget.item.targetCount > 0)
            ? widget.item.targetCount.toString()
            : '');
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant GoalItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newText =
        (widget.item.targetCount > 0) ? widget.item.targetCount.toString() : '';
    if (newText != _controller.text && !_focusNode.hasFocus) {
      _controller.text = newText;
    }
    if (widget.item.isActive != oldWidget.item.isActive) {
      if (widget.item.isActive) {
        _controller.text = (widget.item.targetCount > 0)
            ? widget.item.targetCount.toString()
            : '10';
      } else {
        _controller.text = '';
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _saveValue();
    }
  }

  void _saveValue() {
    final notifier = ref.read(goalManagementStateProvider.notifier);
    if (!widget.item.isActive) return;

    int newCount = int.tryParse(_controller.text) ?? 0;
    if (newCount == 0) {
      newCount = 10;
      _controller.text = '10';
    }
    if (newCount == widget.item.targetCount) return;

    notifier.setGoal(widget.item.tasbih.id, newCount);
  }

  void _handleActivation(bool? isActivating) {
    // لا تفعل شيئًا إذا كان الذكر أساسيًا
    if (isActivating == null || widget.item.tasbih.isDefault) return;

    final notifier = ref.read(goalManagementStateProvider.notifier);
    notifier.toggleActivation(widget.item.tasbih.id, isActivating);
    if (isActivating) {
      _focusNode.requestFocus();
    }
  }

  String _getRepetitionWord(int count) {
    if (count == 2) return 'مرتان';
    if (count >= 3 && count <= 10) {
      return 'مرات';
    }
    return 'مرة';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = widget.item.tasbih.isDefault;
    final count = int.tryParse(_controller.text) ?? 0;

    // اللون الخاص بعلامة الصح للذكر الأساسي
    final Color defaultCheckColor = Colors.green.shade800;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بناء Checkbox مع منطق التمييز
              Transform.scale(
                scale: 1.2,
                child: Checkbox(
                  value: widget.item.isActive,
                  onChanged: _handleActivation,
                  activeColor: isDefault
                      ? Colors.green.withOpacity(0.3)
                      : theme.colorScheme.secondary,
                  checkColor: Colors.white,
                  // شكل علامة الصح نفسها
                  side: isDefault
                      ? BorderSide(color: defaultCheckColor, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 4.0),
                  child: Text(
                    widget.item.tasbih.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 17,
                        height: 1.5,
                        color:
                            widget.item.isActive ? null : theme.disabledColor),
                  ),
                ),
              ),
            ],
          ),
          if (widget.item.isActive) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 48.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'هدفي اليومي بإذن الله سيكون:',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: widget.item.isActive,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        NoLeadingZeroFormatter(),
                      ],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: theme.colorScheme.secondary, width: 2),
                        ),
                      ),
                      onEditingComplete: _saveValue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _getRepetitionWord(count),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
