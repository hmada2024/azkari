// lib/features/goal_management/widgets/goal_item_card.dart
import 'package:azkari/core/constants/app_colors.dart';
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
    final isDarkMode = theme.brightness == Brightness.dark;
    final isDeletable = widget.item.tasbih.isDeletable;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 68,
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? AppColors.cardGradientDark
            : AppColors.cardGradientLight,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.25)
                : Colors.blueGrey.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              widget.item.tasbih.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontSize: 16, height: 1.4),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 70,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: theme.colorScheme.secondary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: theme.colorScheme.secondary, width: 2),
                ),
              ),
              onSubmitted: (_) => _saveValue(),
            ),
          ),
          SizedBox(
            width: 48,
            child: isDeletable
                ? IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.delete_outline_rounded,
                        color: theme.colorScheme.error.withOpacity(0.8)),
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
                : Icon(Icons.lock_outline_rounded, color: theme.disabledColor),
          ),
        ],
      ),
    );
  }
}
