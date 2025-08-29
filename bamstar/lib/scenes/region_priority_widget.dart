import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'region_preference_sheet.dart';

class RegionPriorityWidget extends StatelessWidget {
  final List<AreaGroup> selectedAreas;
  final ValueNotifier<List<AreaGroup>> selected;
  
  const RegionPriorityWidget({
    super.key,
    required this.selectedAreas,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedAreas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // 우선순위 설정 안내
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                '드래그해서 우선순위를 설정하세요 (1순위가 가장 중요)',
                style: AppTextStyles.captionText(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 드래그 가능한 우선순위 리스트
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final newList = List<AreaGroup>.from(selectedAreas);
            final item = newList.removeAt(oldIndex);
            newList.insert(newIndex, item);
            selected.value = newList;
          },
          children: selectedAreas.asMap().entries.map((entry) {
            final index = entry.key;
            final area = entry.value;
            return Container(
              key: ValueKey(area.id),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 우선순위 번호
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.chipLabel(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 지역명
                  Expanded(
                    child: Text(
                      area.name,
                      style: AppTextStyles.primaryText(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // 드래그 핸들
                  Icon(
                    Icons.drag_handle,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  // 삭제 버튼
                  GestureDetector(
                    onTap: () {
                      final newList = List<AreaGroup>.from(selectedAreas);
                      newList.removeWhere((e) => e.id == area.id);
                      selected.value = newList;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}