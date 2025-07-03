// lib/features/goal_management/widgets/goal_item_card.dart
import 'package:azkari/core/utils/no_leading_zero_formatter.dart';
import 'package:azkari/core/utils/size_config.dart';
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
    if (isActivating == null || widget.item.tasbih.isMandatory) return;

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
    final isMandatory = widget.item.tasbih.isMandatory;
    final count = int.tryParse(_controller.text) ?? 0;
    final defaultCheckColor = Colors.green.shade800;

    return Container(
      margin: EdgeInsets.symmetric(vertical: context.responsiveSize(4)),
      padding: EdgeInsets.all(context.responsiveSize(10)),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(context.responsiveSize(12)),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: context.responsiveSize(1.0),
                child: Checkbox(
                  value: widget.item.isActive,
                  onChanged: _handleActivation,
                  activeColor: isMandatory
                      ? Colors.green.withOpacity(0.3)
                      : theme.colorScheme.secondary,
                  checkColor: Colors.white,
                  side: isMandatory
                      ? BorderSide(color: defaultCheckColor, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(context.responsiveSize(4))),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: context.responsiveSize(8.0)),
                  child: Text(
                    widget.item.tasbih.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: context.responsiveSize(16),
                        height: 1.5,
                        color:
                            widget.item.isActive ? null : theme.disabledColor),
                  ),
                ),
              ),
            ],
          ),
          if (widget.item.isActive) ...[
            SizedBox(height: context.responsiveSize(4)),
            Padding(
              padding: EdgeInsets.only(right: context.responsiveSize(40.0)),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: context.responsiveSize(6),
                runSpacing: context.responsiveSize(4),
                children: [
                  Text(
                    'هدفي اليومي بإذن الله سيكون:',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: context.responsiveSize(13)),
                  ),
                  SizedBox(
                    width: context.responsiveSize(65),
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
                        fontSize: context.responsiveSize(15),
                        color: theme.colorScheme.secondary,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: context.responsiveSize(8),
                            horizontal: context.responsiveSize(4)),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(context.responsiveSize(8)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(context.responsiveSize(8)),
                          borderSide: BorderSide(
                              color: theme.colorScheme.secondary, width: 2),
                        ),
                      ),
                      onEditingComplete: _saveValue,
                    ),
                  ),
                  Text(
                    _getRepetitionWord(count),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontSize: context.responsiveSize(13)),
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
