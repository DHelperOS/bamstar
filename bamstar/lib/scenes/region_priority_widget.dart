import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import 'region_preference_sheet.dart';

class RegionPriorityWidget extends StatefulWidget {
  final List<AreaGroup> selectedAreas;
  final ValueNotifier<List<AreaGroup>> selected;
  
  const RegionPriorityWidget({
    super.key,
    required this.selectedAreas,
    required this.selected,
  });

  @override
  State<RegionPriorityWidget> createState() => _RegionPriorityWidgetState();
}

class _RegionPriorityWidgetState extends State<RegionPriorityWidget> {
  late List<AreaGroup> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.selectedAreas);
  }

  @override
  void didUpdateWidget(RegionPriorityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAreas != widget.selectedAreas) {
      _items = List.from(widget.selectedAreas);
    }
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      widget.selected.value = _items;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 우선순위 설정 안내
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '드래그해서 우선순위를 설정하세요',
                style: AppTextStyles.captionText(context).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 드래그 가능한 우선순위 리스트
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          onReorder: _onReorder,
          itemCount: _items.length,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Material(
                  elevation: 0,
                  color: Colors.transparent,
                  child: child,
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final area = _items[index];
            return Container(
              key: ValueKey('priority_${area.id}'),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 드래그 핸들 - 맨 왼쪽으로 이동
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                    ),
                  ),
                  // 우선순위 번호 - Primary color only for sequence numbers
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 지역명 - Smaller text size
                  Expanded(
                    child: Text(
                      area.name,
                      style: AppTextStyles.captionText(context).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  // 삭제 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _items.removeWhere((e) => e.id == area.id);
                        widget.selected.value = _items;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 12,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}