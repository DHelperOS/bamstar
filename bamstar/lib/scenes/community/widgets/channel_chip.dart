import 'package:flutter/material.dart';
import '../../../theme/typography.dart';
import '../../../theme/app_text_styles.dart';

class ChannelChip extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback? onTap;
  const ChannelChip({
    super.key,
    required this.name,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text('#$name'),
        selected: selected,
        onSelected: (_) => onTap?.call(),
        selectedColor: cs.primary,
        labelStyle: AppTextStyles.chipLabel(context).copyWith(color: selected ? cs.onPrimary : cs.onSurface),
        backgroundColor: cs.surface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? cs.primary : cs.outlineVariant),
        ),
      ),
    );
  }
}
