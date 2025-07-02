// lib/features/goal_management/widgets/goal_item_card.dart
import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/goal_management/widgets/management_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GoalItemCard extends ConsumerStatefulWidget {
  final GoalManagementItem item;
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
    _controller =
        TextEditingController(text: widget.item.targetCount.toString());
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant GoalItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.targetCount.toString() != _controller.text) {
      _controller.text = widget.item.targetCount.toString();
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
    final newCount = int.tryParse(_controller.text) ?? 0;
    if (newCount == widget.item.targetCount) return;
    ref
        .read(goalManagementStateProvider.notifier)
        .setGoal(widget.item.tasbih.id, newCount)
        .then((success) {
      if (!success && mounted) {
        setState(() {
          _controller.text = widget.item.targetCount.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeletable = widget.item.tasbih.isDeletable;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Text(
                widget.item.tasbih.displayName,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(height: 1.4),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: theme.primaryColor,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: theme.primaryColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _saveValue(),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: isDeletable
                    ? IconButton(
                        icon: Icon(Icons.delete_outline_rounded,
                            color: theme.colorScheme.error),
                        onPressed: () {
                          showDeleteConfirmationDialog(
                            context: context,
                            tasbihName: widget.item.tasbih.displayName,
                            onConfirm: () {
                              ref
                                  .read(goalManagementStateProvider.notifier)
                                  .deleteTasbih(widget.item.tasbih.id);
                            },
                          );
                        },
                      )
                    : Icon(Icons.lock_outline_rounded,
                        color: theme.disabledColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
