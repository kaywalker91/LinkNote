import 'package:flutter/material.dart';
import 'package:linknote/core/utils/debouncer.dart';

class AppSearchBarWidget extends StatefulWidget {
  const AppSearchBarWidget({
    required this.controller,
    required this.onChanged,
    super.key,
    this.onClear,
    this.hintText = 'Search links, notes, tags',
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String hintText;

  @override
  State<AppSearchBarWidget> createState() => _AppSearchBarWidgetState();
}

class _AppSearchBarWidgetState extends State<AppSearchBarWidget> {
  late final Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: (value) => _debouncer(() => widget.onChanged(value)),
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: widget.controller,
          builder: (context, value, child) => value.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onClear?.call();
                    widget.onChanged('');
                  },
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
