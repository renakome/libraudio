import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:musily/core/utils/platform_optimizer.dart';

/// Optimized ListView with platform-specific configurations for better performance
/// This widget automatically applies the best settings based on the current platform
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final double? itemExtent;
  final Widget? prototypeItem;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const OptimizedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.itemExtent,
    this.prototypeItem,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final listConfig = PlatformOptimizer.getOptimalListViewConfig();

    return ListView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? (PlatformOptimizer.isMobile ? const BouncingScrollPhysics() : null),
      shrinkWrap: listConfig.enableShrinkWrap || shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      // Apply platform-optimized cache extent
      cacheExtent: listConfig.cacheExtent,
      // Apply platform-optimized child configurations
      addAutomaticKeepAlives: listConfig.addAutomaticKeepAlives && addAutomaticKeepAlives,
      addRepaintBoundaries: listConfig.addRepaintBoundaries && addRepaintBoundaries,
      addSemanticIndexes: listConfig.addSemanticIndexes && addSemanticIndexes,
      children: children,
    );
  }
}

/// Optimized ListView.builder with platform-specific configurations
class OptimizedListViewBuilder extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? itemExtent;
  final Widget? prototypeItem;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const OptimizedListViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.itemExtent,
    this.prototypeItem,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final listConfig = PlatformOptimizer.getOptimalListViewConfig();

    // If we have separators, use a different approach
    if (separatorBuilder != null) {
      return ListView.separated(
        key: key,
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: physics ?? (PlatformOptimizer.isMobile ? const BouncingScrollPhysics() : null),
        shrinkWrap: listConfig.enableShrinkWrap || shrinkWrap,
        padding: padding,
        itemCount: itemCount,
        cacheExtent: listConfig.cacheExtent,
        separatorBuilder: separatorBuilder!,
        itemBuilder: (context, index) {
          // Add platform-specific optimizations for item building
          if (PlatformOptimizer.isMobile) {
            // On mobile, use AutomaticKeepAlive for better performance
            return AutomaticKeepAlive(
              key: ValueKey('item_$index'),
              child: itemBuilder(context, index),
            );
          } else {
            // On desktop, simpler approach for better performance
            return itemBuilder(context, index);
          }
        },
      );
    }

    // Standard ListView.builder for better performance
    return ListView.builder(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? (PlatformOptimizer.isMobile ? const BouncingScrollPhysics() : null),
      shrinkWrap: listConfig.enableShrinkWrap || shrinkWrap,
      padding: padding,
      itemExtent: itemExtent,
      prototypeItem: prototypeItem,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      // Apply platform-optimized cache extent
      cacheExtent: listConfig.cacheExtent,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Add platform-specific optimizations for item building
        if (PlatformOptimizer.isMobile) {
          // On mobile, use AutomaticKeepAlive for better performance
          return AutomaticKeepAlive(
            key: ValueKey('item_$index'),
            child: itemBuilder(context, index),
          );
        } else {
          // On desktop, simpler approach for better performance
          return itemBuilder(context, index);
        }
      },
    );
  }
}

/// Optimized GridView with platform-specific configurations
class OptimizedGridView extends StatelessWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final SliverGridDelegate gridDelegate;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  const OptimizedGridView({
    super.key,
    required this.children,
    required this.gridDelegate,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  });

  @override
  Widget build(BuildContext context) {
    final listConfig = PlatformOptimizer.getOptimalListViewConfig();

    return GridView(
      key: key,
      scrollDirection: scrollDirection,
      reverse: reverse,
      controller: controller,
      primary: primary,
      physics: physics ?? (PlatformOptimizer.isMobile ? const BouncingScrollPhysics() : null),
      shrinkWrap: listConfig.enableShrinkWrap || shrinkWrap,
      padding: padding,
      gridDelegate: gridDelegate,
      semanticChildCount: semanticChildCount,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      // Apply platform-optimized cache extent
      cacheExtent: listConfig.cacheExtent,
      // Apply platform-optimized child configurations
      addAutomaticKeepAlives: listConfig.addAutomaticKeepAlives && addAutomaticKeepAlives,
      addRepaintBoundaries: listConfig.addRepaintBoundaries && addRepaintBoundaries,
      addSemanticIndexes: listConfig.addSemanticIndexes && addSemanticIndexes,
      children: children,
    );
  }
}

/// Lazy loading builder for paginated content with platform optimizations
class OptimizedLazyListView<T> extends StatefulWidget {
  final Future<List<T>> Function(int page, int limit) loadPage;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  final int initialLimit;
  final int pageSize;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;

  const OptimizedLazyListView({
    super.key,
    required this.loadPage,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.initialLimit = 20,
    this.pageSize = 20,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.controller,
  });

  @override
  State<OptimizedLazyListView<T>> createState() => _OptimizedLazyListViewState<T>();
}

class _OptimizedLazyListViewState<T> extends State<OptimizedLazyListView<T>> {
  final List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  Object? _error;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await widget.loadPage(0, widget.initialLimit);
      setState(() {
        _items.addAll(items);
        _currentPage = 0;
        _hasMore = items.length >= widget.initialLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final items = await widget.loadPage(nextPage, widget.pageSize);

      setState(() {
        _items.addAll(items);
        _currentPage = nextPage;
        _hasMore = items.length >= widget.pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return widget.errorBuilder?.call(context, _error) ??
          Center(child: Text('Error: $_error'));
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('No items found'));
    }

    return OptimizedListViewBuilder(
      controller: widget.controller,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          // Loading indicator at the end
          if (_isLoading) {
            return widget.loadingBuilder?.call(context) ??
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
          } else {
            // Trigger loading more data when reaching near the end
            WidgetsBinding.instance.addPostFrameCallback((_) => _loadMoreData());
            return const SizedBox.shrink();
          }
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );
  }
}
