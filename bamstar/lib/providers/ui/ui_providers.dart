import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// 하단 네비게이션 인덱스 Provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// 테마 모드 Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);
  
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
  
  void toggleTheme() {
    state = state == ThemeMode.light 
      ? ThemeMode.dark 
      : ThemeMode.light;
  }
}

/// 로딩 오버레이 Provider
final loadingOverlayProvider = StateProvider<bool>((ref) => false);

/// 스낵바 메시지 Provider
final snackbarMessageProvider = StateProvider<String?>((ref) => null);

/// 검색 쿼리 Provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// 선택된 탭 Provider (탭이 있는 화면용)
final selectedTabProvider = StateProvider.family<int, String>(
  (ref, screenId) => 0,
);

/// 모달/시트 상태 Provider
final modalStateProvider = StateProvider<ModalState?>((ref) => null);

class ModalState {
  final String id;
  final Widget content;
  final bool isDismissible;
  
  const ModalState({
    required this.id,
    required this.content,
    this.isDismissible = true,
  });
}

/// 폼 검증 Provider
final formValidationProvider = StateNotifierProvider.family<
  FormValidationNotifier,
  Map<String, String?>,
  String
>((ref, formId) => FormValidationNotifier());

class FormValidationNotifier extends StateNotifier<Map<String, String?>> {
  FormValidationNotifier() : super({});
  
  void setError(String field, String? error) {
    state = {...state, field: error};
  }
  
  void clearError(String field) {
    final newState = {...state};
    newState.remove(field);
    state = newState;
  }
  
  void clearAll() {
    state = {};
  }
  
  bool get isValid => state.values.every((error) => error == null);
}

/// 스크롤 위치 Provider (스크롤 위치 유지용)
final scrollPositionProvider = StateProvider.family<double, String>(
  (ref, screenId) => 0.0,
);

/// 새로고침 트리거 Provider
final refreshTriggerProvider = StateProvider.family<int, String>(
  (ref, screenId) => 0,
);

/// 페이지 상태 Provider (페이지별 상태 관리)
final pageStateProvider = StateNotifierProvider.family<
  PageStateNotifier,
  PageState,
  String
>((ref, pageId) => PageStateNotifier());

class PageStateNotifier extends StateNotifier<PageState> {
  PageStateNotifier() : super(const PageState());
  
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }
  
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }
  
  void setData(dynamic data) {
    state = state.copyWith(data: data, isLoading: false, error: null);
  }
  
  void reset() {
    state = const PageState();
  }
}

class PageState {
  final bool isLoading;
  final String? error;
  final dynamic data;
  
  const PageState({
    this.isLoading = false,
    this.error,
    this.data,
  });
  
  PageState copyWith({
    bool? isLoading,
    String? error,
    dynamic data,
  }) {
    return PageState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      data: data ?? this.data,
    );
  }
}

/// 애니메이션 상태 Provider
final animationStateProvider = StateProvider.family<bool, String>(
  (ref, animationId) => false,
);

/// 드래그 상태 Provider (드래그 앤 드롭용)
final dragStateProvider = StateProvider<DragState?>((ref) => null);

class DragState {
  final String itemId;
  final Offset position;
  final dynamic data;
  
  const DragState({
    required this.itemId,
    required this.position,
    this.data,
  });
}

/// 필터 상태 Provider (다중 필터용)
final filterStateProvider = StateNotifierProvider<FilterStateNotifier, FilterState>(
  (ref) => FilterStateNotifier(),
);

class FilterStateNotifier extends StateNotifier<FilterState> {
  FilterStateNotifier() : super(const FilterState());
  
  void setFilter(String key, dynamic value) {
    state = state.copyWith(filters: {...state.filters, key: value});
  }
  
  void removeFilter(String key) {
    final newFilters = {...state.filters};
    newFilters.remove(key);
    state = state.copyWith(filters: newFilters);
  }
  
  void clearFilters() {
    state = const FilterState();
  }
  
  void setSort(String field, bool ascending) {
    state = state.copyWith(
      sortField: field,
      sortAscending: ascending,
    );
  }
}

class FilterState {
  final Map<String, dynamic> filters;
  final String? sortField;
  final bool sortAscending;
  
  const FilterState({
    this.filters = const {},
    this.sortField,
    this.sortAscending = true,
  });
  
  FilterState copyWith({
    Map<String, dynamic>? filters,
    String? sortField,
    bool? sortAscending,
  }) {
    return FilterState(
      filters: filters ?? this.filters,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

/// 키보드 가시성 Provider
final keyboardVisibilityProvider = StateProvider<bool>((ref) {
  return false; // MediaQuery.of(context).viewInsets.bottom > 0 으로 업데이트
});

/// 디바이스 방향 Provider
final deviceOrientationProvider = StateProvider<Orientation>((ref) {
  return Orientation.portrait;
});

/// 화면 크기 Provider
final screenSizeProvider = StateProvider<Size>((ref) {
  return Size.zero; // MediaQuery.of(context).size 로 업데이트
});

/// 플랫폼 Provider
final platformProvider = Provider<TargetPlatform>((ref) {
  return TargetPlatform.iOS; // Theme.of(context).platform 으로 업데이트
});