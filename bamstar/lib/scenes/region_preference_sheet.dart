import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:choice/choice.dart';
import 'package:logging/logging.dart';
import '../theme/app_text_styles.dart';
import 'member_profile/services/region_preference_service.dart';
import '../utils/toast_helper.dart';
import 'region_priority_widget.dart';

// Data models
class MainCategory {
  final int id;
  final String name;
  const MainCategory({required this.id, required this.name});
}

class AreaGroup {
  final int id;
  final String name;
  final int mainCategoryId;
  const AreaGroup({
    required this.id,
    required this.name,
    required this.mainCategoryId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is AreaGroup && other.id == id);
  @override
  int get hashCode => id.hashCode;
}

// Route entry - changed to regular page route
Route<List<AreaGroup>?> preferredRegionSheetRoute() {
  return MaterialPageRoute<List<AreaGroup>?>(
    builder: (context) => const RegionPreferencePage(),
  );
}

// Main page widget
class RegionPreferencePage extends StatefulWidget {
  const RegionPreferencePage({super.key});

  @override
  State<RegionPreferencePage> createState() => _RegionPreferencePageState();
}

class _RegionPreferencePageState extends State<RegionPreferencePage> {
  bool _loading = true;
  String? _error;
  List<MainCategory> _categories = const [];
  final Map<int, List<AreaGroup>> _groupsByCategory = {};
  final ValueNotifier<List<AreaGroup>> _selected = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _selected.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final log = Logger('region_preference_sheet');
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supa = Supabase.instance.client;

      // Fetch categories
      final catsDataRaw = await supa
          .from('main_categories')
          .select('category_id,name')
          .order('category_id', ascending: true);
      final catsList = (catsDataRaw as List).cast<Map<String, dynamic>>();
      final cats = <MainCategory>[];
      for (final row in catsList) {
        final idVal = row['category_id'];
        final nameVal = row['name'];
        if (idVal != null && nameVal != null) {
          final nameStr = nameVal.toString().trim();
          if (nameStr.isEmpty) continue;
          cats.add(MainCategory(id: (idVal as num).toInt(), name: nameStr));
        }
      }

      // Fetch area groups
      final groupsDataRaw = await supa
          .from('area_groups')
          .select('group_id,name,category_id')
          .order('group_id', ascending: true)
          .order('category_id', ascending: true);
      final groupsList = (groupsDataRaw as List).cast<Map<String, dynamic>>();
      final groups = <AreaGroup>[];
      for (final row in groupsList) {
        final idVal = row['group_id'];
        final nameVal = row['name'];
        final categoryIdVal = row['category_id'];
        if (idVal != null && nameVal != null && categoryIdVal != null) {
          final nameStr = nameVal.toString().trim();
          if (nameStr.isEmpty) continue;
          groups.add(
            AreaGroup(
              id: (idVal as num).toInt(),
              name: nameStr,
              mainCategoryId: (categoryIdVal as num).toInt(),
            ),
          );
        }
      }

      // Group by category
      final groupsByCategory = <int, List<AreaGroup>>{};
      for (final g in groups) {
        groupsByCategory.putIfAbsent(g.mainCategoryId, () => []).add(g);
      }

      // Load current selections
      final currentSelections = await RegionPreferenceService.instance
          .loadPreferredAreaGroups();
      final initialSelected = <AreaGroup>[];
      for (final groupId in currentSelections) {
        final matchingGroup = groups.where((g) => g.id == groupId).firstOrNull;
        if (matchingGroup != null) {
          initialSelected.add(matchingGroup);
        }
      }

      setState(() {
        _categories = cats;
        _groupsByCategory.clear();
        _groupsByCategory.addAll(groupsByCategory);
        _selected.value = initialSelected;
        _loading = false;
      });

      log.fine(
        '[region] loaded ${cats.length} categories, ${groups.length} groups',
      );
    } catch (e, st) {
      log.warning('[region] fetch error: $e', e, st);
      setState(() {
        _loading = false;
        _error = '지역 정보를 불러오지 못했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('선호 지역 선택', style: AppTextStyles.pageTitle(context)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        toolbarHeight: 50, // 기본 56에서 50으로 감소
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: AppTextStyles.primaryText(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            )
          : ValueListenableBuilder<List<AreaGroup>>(
              valueListenable: _selected,
              builder: (context, selectedList, _) {
                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Region selection tabs
                            _RegionPreferenceContent(
                              categories: _categories,
                              groupsByCategory: _groupsByCategory,
                              selected: _selected,
                            ),

                            const SizedBox(height: 16),

                            // Selection summary - moved below
                            if (selectedList.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '선택된 지역: ${selectedList.length}/5 개',
                                      style: AppTextStyles.formLabel(context),
                                    ),
                                    const SizedBox(height: 12),
                                    RegionPriorityWidget(
                                      selectedAreas: selectedList,
                                      selected: _selected,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Bottom save button
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final areaGroupIds = selectedList
                                .map((area) => area.id)
                                .toList();
                            final success = await RegionPreferenceService
                                .instance
                                .savePreferredAreaGroups(areaGroupIds);

                            if (success) {
                              if (mounted) {
                                Navigator.of(context).pop(selectedList);
                              }
                            } else {
                              if (mounted) {
                                ToastHelper.error(context, '저장 중 오류가 발생했습니다');
                              }
                            }
                          },
                          child: Text(
                            '완료',
                            style: AppTextStyles.buttonText(context).copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _RegionPreferenceContent extends StatefulWidget {
  final List<MainCategory> categories;
  final Map<int, List<AreaGroup>> groupsByCategory;
  final ValueNotifier<List<AreaGroup>> selected;

  const _RegionPreferenceContent({
    required this.categories,
    required this.groupsByCategory,
    required this.selected,
  });

  @override
  State<_RegionPreferenceContent> createState() =>
      _RegionPreferenceContentState();
}

class _RegionPreferenceContentState extends State<_RegionPreferenceContent>
    with SingleTickerProviderStateMixin {
  static const int _kMax = 5;
  late final TabController _tabController;
  late final List<MainCategory> _effectiveCategories;

  @override
  void initState() {
    super.initState();
    _effectiveCategories = widget.categories
        .where((c) => c.name.trim().isNotEmpty)
        .toList();
    final len = _effectiveCategories.isEmpty ? 1 : _effectiveCategories.length;
    _tabController = TabController(length: len, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLimitToast() {
    ToastHelper.warning(context, '지역은 최대 5개까지만 선택할 수 있습니다.');
  }

  void _updateSelectionForCategory(
    int categoryId,
    List<int> newIds,
    List<AreaGroup> items,
  ) {
    final current = widget.selected.value;
    final others = current
        .where((g) => g.mainCategoryId != categoryId)
        .toList(growable: true);
    final byId = {for (final g in items) g.id: g};
    final toAdd = newIds.map((id) => byId[id]).whereType<AreaGroup>().toList();
    final newAll = [...others, ...toAdd];
    if (newAll.length > _kMax) {
      _showLimitToast();
      return;
    }
    widget.selected.value = newAll;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = _effectiveCategories;
    final groupsByCat = widget.groupsByCategory;

    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Simple TabBar
          Container(
            margin: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                indicatorSize: TabBarIndicatorSize.tab,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: cs.onSurfaceVariant,
                labelStyle: AppTextStyles.chipLabel(
                  context,
                ).copyWith(fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTextStyles.chipLabel(context),
                dividerColor: Colors.transparent,
                tabs: categories.isEmpty
                    ? [const Tab(text: '지역')]
                    : categories.map((c) => Tab(text: c.name)).toList(),
              ),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<AreaGroup>>(
              valueListenable: widget.selected,
              builder: (context, selected, _) {
                final selectedIds = selected.map((e) => e.id).toSet();
                return TabBarView(
                  controller: _tabController,
                  children: categories.isEmpty
                      ? [const SizedBox.shrink()]
                      : categories.map((cat) {
                          final items =
                              groupsByCat[cat.id] ?? const <AreaGroup>[];
                          final value = items
                              .where((g) => selectedIds.contains(g.id))
                              .map((g) => g.id)
                              .toList(growable: false);
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Choice<int>.inline(
                              multiple: true,
                              value: value,
                              onChanged: (ids) => _updateSelectionForCategory(
                                cat.id,
                                ids,
                                items,
                              ),
                              itemCount: items.length,
                              itemBuilder: (state, i) {
                                final g = items[i];
                                final isSelected = state.selected(g.id);
                                final disabled =
                                    !isSelected && selected.length >= _kMax;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? cs.primary
                                        : disabled
                                        ? cs.surfaceContainerHighest.withValues(
                                            alpha: 0.5,
                                          )
                                        : cs.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? null
                                        : Border.all(
                                            color: cs.outline.withValues(
                                              alpha: 0.1,
                                            ),
                                            width: 1,
                                          ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: disabled
                                          ? null
                                          : () => state.onSelected(g.id)(
                                              !isSelected,
                                            ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          g.name,
                                          style:
                                              AppTextStyles.chipLabel(
                                                context,
                                              ).copyWith(
                                                color: isSelected
                                                    ? cs.onPrimary
                                                    : disabled
                                                    ? cs.onSurfaceVariant
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : cs.onSurfaceVariant,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : null,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
