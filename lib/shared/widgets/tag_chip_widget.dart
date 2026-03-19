import 'package:flutter/material.dart';

class TagChipWidget extends StatelessWidget {
  const TagChipWidget({
    required this.label,
    super.key,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.isDense = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (onDelete != null) {
      return InputChip(
        label: Text(label),
        onPressed: onTap,
        onDeleted: onDelete,
        selected: isSelected,
        padding: isDense
            ? const EdgeInsets.symmetric(horizontal: 4)
            : null,
      );
    }
    return FilterChip(
      label: Text(label),
      onSelected: onTap != null ? (_) => onTap!() : null,
      selected: isSelected,
      selectedColor: colorScheme.primaryContainer,
      padding: isDense
          ? const EdgeInsets.symmetric(horizontal: 4)
          : null,
    );
  }
}
