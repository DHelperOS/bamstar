import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
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

// Route entry
Route<List<AreaGroup>?> preferredRegionSheetRoute() {
  return PageRouteBuilder<List<AreaGroup>?>(
    opaque: false,
    barrierColor: const Color.fromRGBO(0, 0, 0, 0.35),
    pageBuilder: (context, _, __) => const _RegionPreferenceSheetLauncher(),
  );
}

// Launcher: fetch data, then open modal
class _RegionPreferenceSheetLauncher extends StatefulWidget {
  const _RegionPreferenceSheetLauncher({Key? key}) : super(key: key);
  @override
  State<_RegionPreferenceSheetLauncher> createState() =>
      _RegionPreferenceSheetLauncherState();
}

class _RegionPreferenceSheetLauncherState
    extends State<_RegionPreferenceSheetLauncher> {
  bool _loading = true;
  String? _error;
  List<MainCategory> _categories = const [];
  final Map<int, List<AreaGroup>> _groupsByCategory = {};

  @override
  void initState() {
    super.initState();
    _fetchAndOpen();
  }

  Future<void> _fetchAndOpen() async {
    final log = Logger('region_preference_sheet');
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supa = Supabase.instance.client;

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
          if (nameStr.isEmpty) continue; // skip empty/whitespace names
          cats.add(MainCategory(id: (idVal as num).toInt(), name: nameStr));
        }
      }

      final groupsDataRaw = await supa
          .from('area_groups')
          .select('group_id,name,category_id')
          .order('group_id', ascending: true)
          .order('category_id', ascending: true);
      final groupsList = (groupsDataRaw as List).cast<Map<String, dynamic>>();
      final groups = <AreaGroup>[];
      for (final row in groupsList) {
        final gid = row['group_id'];
        final gname = row['name'];
        final cid = row['category_id'];
        if (gid != null && gname != null && cid != null) {
          groups.add(
            AreaGroup(
              id: (gid as num).toInt(),
              name: gname.toString(),
              mainCategoryId: (cid as num).toInt(),
            ),
          );
        }
      }

      final map = <int, List<AreaGroup>>{};
      for (final g in groups) {
        (map[g.mainCategoryId] ??= []).add(g);
      }

      // Debug
      log.fine('[region] main_categories rows=${cats.length}');
      log.fine('[region] area_groups rows=${groups.length}');
      if (!mounted) return;

      setState(() {
        _categories = cats;
        _groupsByCategory
          ..clear()
          ..addAll(map);
        _loading = false;
      });

      // Load existing preferred area groups
      final preferredGroupIds = await RegionPreferenceService.instance.loadPreferredAreaGroups();
      final allAreaGroups = <AreaGroup>[];
      for (final groups in _groupsByCategory.values) {
        allAreaGroups.addAll(groups);
      }
      final initialSelected = allAreaGroups.where((group) => 
        preferredGroupIds.contains(group.id)
      ).toList();
      
      if (!mounted) return;
      
      final nav = Navigator.of(context);
      WoltModalSheet.show<List<AreaGroup>?>(
        context: context,
        modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
        onModalDismissedWithBarrierTap: () => nav.maybePop(),
        pageListBuilder: (modalCtx) {
          final selected = ValueNotifier<List<AreaGroup>>(initialSelected);
          return [
            _buildRegionPage(
              modalCtx,
              _categories,
              _groupsByCategory,
              selected,
            ),
          ];
        },
      ).then((value) {
        if (!mounted) return;
        nav.maybePop(value);
      });
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
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => !_loading,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _error != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _fetchAndOpen,
                      child: const Text('다시 시도'),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

// Build a Wolt page with a stateful content widget and shared selection notifier
WoltModalSheetPage _buildRegionPage(
  BuildContext ctx,
  List<MainCategory> categories,
  Map<int, List<AreaGroup>> groupsByCategory,
  ValueNotifier<List<AreaGroup>> selected,
) {
  return WoltModalSheetPage(
    backgroundColor: Theme.of(ctx).colorScheme.surface,
    surfaceTintColor: Colors.transparent,
    pageTitle: null,
    leadingNavBarWidget: Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Text('선호 지역 선택', style: AppTextStyles.dialogTitle(ctx)),
    ),
    trailingNavBarWidget: Container(
      margin: const EdgeInsets.only(right: 20.0),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        icon: Icon(
          Icons.close_rounded,
          size: 20,
          color: Theme.of(ctx).colorScheme.onSurfaceVariant,
        ),
        onPressed: () => Navigator.of(ctx).pop(),
      ),
    ),
    stickyActionBar: Container(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
      decoration: BoxDecoration(
        color: Theme.of(ctx).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: ValueListenableBuilder<List<AreaGroup>>(
        valueListenable: selected,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection summary card
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택된 지역: ${value.length}/5 개',
                    style: AppTextStyles.formLabel(context),
                  ),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    RegionPriorityWidget(
                      selectedAreas: value,
                      selected: selected,
                    ),
                  ],
                ],
              ),
            ),
            // Gradient complete button
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    // Save selected area groups to database
                    final areaGroupIds = value.map((area) => area.id).toList();
                    final success = await RegionPreferenceService.instance
                        .savePreferredAreaGroups(areaGroupIds);
                    
                    if (success) {
                      if (ctx.mounted) {
                        ToastHelper.success(ctx, '선호 지역이 저장되었습니다');
                        Navigator.of(ctx).pop(value);
                      }
                    } else {
                      if (ctx.mounted) {
                        ToastHelper.error(ctx, '저장 중 오류가 발생했습니다');
                      }
                    }
                  },
                  child: SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        '완료',
                        style: AppTextStyles.buttonText(context).copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    child: SizedBox(
      height: MediaQuery.of(ctx).size.height * 9,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Helper text
            Text(
              '나를 빛낼 선호 지역을 선택하세요',
              style: AppTextStyles.captionText(
                ctx,
              ).copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Content in card styling
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    ctx,
                  ).colorScheme.outline.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      ctx,
                    ).colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.5,
                child: _RegionPreferenceContent(
                  categories: categories,
                  groupsByCategory: groupsByCategory,
                  selected: selected,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _RegionPreferenceContent extends StatefulWidget {
  final List<MainCategory> categories;
  final Map<int, List<AreaGroup>> groupsByCategory;
  final ValueNotifier<List<AreaGroup>> selected;
  const _RegionPreferenceContent({
    Key? key,
    required this.categories,
    required this.groupsByCategory,
    required this.selected,
  }) : super(key: key);

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
    // debug
    // ignore: avoid_print
    final log = Logger('region_preference_sheet');
    log.fine(
      '[region] effective categories: ${_effectiveCategories.map((c) => c.name).toList()}',
    );
    _tabController = TabController(length: len, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showLimitToast() {
    DelightToastBar(
      builder: (ctx) => const ToastCard(
        title: Text('알림'),
        subtitle: Text('지역은 최대 5개까지만 선택할 수 있습니다.'),
      ),
      autoDismiss: true,
    ).show(context);
  }

  void _updateSelectionForCategory(
    int categoryId,
    List<int> newIds,
    List<AreaGroup> items,
  ) {
    final current = widget.selected.value;
    // Remove previous selections for this category
    final others = current
        .where((g) => g.mainCategoryId != categoryId)
        .toList(growable: true);
    final byId = {for (final g in items) g.id: g};
    final toAdd = newIds.map((id) => byId[id]).whereType<AreaGroup>().toList();
    final newAll = [...others, ...toAdd];
    if (newAll.length > _kMax) {
      _showLimitToast();
      return; // do not change selection
    }
    widget.selected.value = newAll;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = _effectiveCategories;
    final groupsByCat = widget.groupsByCategory;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Modern TabBar styling
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            height: 48,
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
                        return Choice<int>.inline(
                          multiple: true,
                          value: value,
                          onChanged: (ids) =>
                              _updateSelectionForCategory(cat.id, ids, items),
                          itemCount: items.length,
                          itemBuilder: (state, i) {
                            final g = items[i];
                            final isSelected = state.selected(g.id);
                            final disabled =
                                !isSelected && selected.length >= _kMax;
                            final csLocal = Theme.of(context).colorScheme;
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? csLocal.primary
                                    : disabled
                                    ? csLocal.surfaceContainerHighest
                                          .withValues(alpha: 0.5)
                                    : csLocal.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? null
                                    : Border.all(
                                        color: csLocal.outline.withValues(
                                          alpha: 0.1,
                                        ),
                                        width: 1,
                                      ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: csLocal.primary.withValues(
                                            alpha: 0.15,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: disabled
                                      ? null
                                      : () => state.onSelected(g.id)(!isSelected),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (isSelected) ...[
                                          Icon(
                                            Icons.check_rounded,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(
                                          g.name,
                                          style:
                                              AppTextStyles.chipLabel(
                                                context,
                                              ).copyWith(
                                                color: isSelected
                                                    ? Colors.white
                                                    : disabled
                                                    ? csLocal.onSurface
                                                          .withValues(
                                                            alpha: 0.5,
                                                          )
                                                    : csLocal.onSurface,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          listBuilder: ChoiceList.createWrapped(
                            spacing: 12,
                            runSpacing: 12,
                            padding: const EdgeInsets.all(0),
                          ),
                        );
                      }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
