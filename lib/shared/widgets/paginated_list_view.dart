import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_spacing.dart';

class PaginatedListView<T> extends StatefulWidget {
  const PaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onRefresh,
    required this.onLoadMore,
    required this.hasMore,
    required this.isLoadingMore,
    super.key,
    this.empty,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.loadMoreError,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? empty;
  final EdgeInsetsGeometry padding;
  final Object? loadMoreError;

  @override
  State<PaginatedListView<T>> createState() => _PaginatedListViewState<T>();
}

class _PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.empty != null) {
      return widget.empty!;
    }
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: widget.padding,
        itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: widget.isLoadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : widget.loadMoreError != null
                  ? Center(
                      child: TextButton.icon(
                        onPressed: widget.onLoadMore,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }
          return widget.itemBuilder(context, widget.items[index], index);
        },
      ),
    );
  }
}
