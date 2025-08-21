import 'package:flutter/material.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:choice/choice.dart';
import 'package:logging/logging.dart';

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

      final nav = Navigator.of(context);
      WoltModalSheet.show<List<AreaGroup>?>(
        context: context,
        modalTypeBuilder: (_) => WoltModalType.bottomSheet(),
        onModalDismissedWithBarrierTap: () => nav.maybePop(),
        pageListBuilder: (modalCtx) {
          final selected = ValueNotifier<List<AreaGroup>>([]);
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
    // Page header
    pageTitle: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        '나를 빛낼 선호 지역을 선택하세요.',
        style: Theme.of(
          ctx,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
    trailingNavBarWidget: IconButton(
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      onPressed: () => Navigator.of(ctx).pop(),
      icon: const Icon(SolarIconsOutline.closeCircle, size: 20),
    ),
    stickyActionBar: Padding(
      padding: const EdgeInsets.all(16.0),
      child: ValueListenableBuilder<List<AreaGroup>>(
        valueListenable: selected,
        builder: (context, value, _) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 28 / 255),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '선택된 지역: ${value.length}/5 개',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (value.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: value.map((g) {
                        return InputChip(
                          label: Text(
                            g.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          onDeleted: () {
                            final newList = List<AreaGroup>.from(value);
                            newList.removeWhere((e) => e.id == g.id);
                            selected.value = newList;
                          },
                          deleteIcon: const Icon(Icons.close, size: 14),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(value),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('완료'),
            ),
          ],
        ),
      ),
    ),
    child: SizedBox(
      // Reduce overall popup height
      height: MediaQuery.of(ctx).size.height * 0.6,
      child: _RegionPreferenceContent(
        categories: categories,
        groupsByCategory: groupsByCategory,
        selected: selected,
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
        // TabBar at the very top without padding (reduced height)
        SizedBox(
          height: 46,
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.only(left: 16, right: 12),
              indicatorPadding: EdgeInsets.zero,
              dividerColor: Colors.transparent,
              tabAlignment: TabAlignment.start,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: Colors.transparent,
              tabs: categories.isEmpty
                  ? [const Tab(text: '지역')]
                  : categories.map((c) => Tab(text: c.name)).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
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
                            return ChoiceChip(
                              selected: isSelected,
                              onSelected: disabled
                                  ? null
                                  : state.onSelected(g.id),
                              label: Text(
                                g.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              selectedColor: csLocal.primaryContainer,
                              showCheckmark: true,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? csLocal.onPrimaryContainer
                                    : csLocal.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              side: BorderSide(
                                color: csLocal.outline.withValues(
                                  alpha: 28 / 255,
                                ),
                                width: 1,
                              ),
                              backgroundColor: disabled
                                  ? csLocal.surfaceContainerHighest
                                  : csLocal.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                          listBuilder: ChoiceList.createWrapped(
                            spacing: 10,
                            runSpacing: 10,
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                          ),
                        );
                      }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
