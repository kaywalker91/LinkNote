import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';

class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.dataBuilder,
    required this.loading,
    super.key,
    this.errorBuilder,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final Widget loading;
  final Widget Function(Object error, StackTrace stack)? errorBuilder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading,
      error: (error, stack) =>
          errorBuilder?.call(error, stack) ??
          ErrorStateWidget(
            message: error.toString(),
            onRetry: onRetry,
          ),
      data: dataBuilder,
    );
  }
}
