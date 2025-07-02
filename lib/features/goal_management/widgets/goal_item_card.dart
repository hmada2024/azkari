// lib/features/goal_management/widgets/goal_item_card.dart

import 'package:azkari/features/goal_management/providers/goal_management_provider.dart';
import 'package:azkari/features/goal_management/widgets/management_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ويدجت يمثل بطاقة عرض وتعديل عنصر واحد في شاشة إدارة الأهداف.
/// يدعم التعديل المباشر للأرقام والحذف للأذكار المخصصة.
class GoalItemCard extends ConsumerStatefulWidget {
  final GoalManagementItem item;
  final BoxConstraints constraints;

  const GoalItemCard({
    super.key,
    required this.item,
    required this.constraints,
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
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // إذا فقد الحقل التركيز، قم بحفظ القيمة
    if (!_focusNode.hasFocus) {
      _saveValue();
    }
  }

  void _saveValue() {
    final newCount = int.tryParse(_controller.text) ?? 0;
    // لا تفعل شيئًا إذا لم تتغير القيمة
    if (newCount == widget.item.targetCount) return;

    ref
        .read(goalManagementStateProvider.notifier)
        .setGoal(widget.item.tasbih.id, newCount)
        .then((success) {
      // إذا فشل الحفظ (لأن الرقم < 10)، أعد القيمة القديمة
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
    final screenWidth = widget.constraints.maxWidth;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // --- العمود الأول: نص الذكر (60%) ---
            SizedBox(
              width: screenWidth * 0.60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.item.tasbih.displayName,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
            // --- فاصل (2%) ---
            SizedBox(width: screenWidth * 0.02),
            // --- العمود الثاني: حقل العدد (25%) ---
            SizedBox(
              width: screenWidth * 0.25,
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
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                onSubmitted: (_) => _saveValue(),
              ),
            ),
            // --- فاصل (1%) ---
            SizedBox(width: screenWidth * 0.01),
            // --- العمود الثالث: أيقونة الإجراء (10%) ---
            Expanded(
              child: Center(
                child: widget.item.tasbih.isDeletable
                    ? IconButton(
                        icon: Icon(Icons.delete_forever_rounded,
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
                    : Icon(Icons.lock_rounded, color: theme.disabledColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
