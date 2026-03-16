import 'dart:async';

import 'package:linknote/core/constants/app_constants.dart';

class Debouncer {
  Debouncer({this.duration = AppConstants.searchDebounce});

  final Duration duration;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
