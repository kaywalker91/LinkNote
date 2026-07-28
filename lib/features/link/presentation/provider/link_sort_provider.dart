import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:linknote/core/logger/app_logger.dart';
import 'package:linknote/features/link/domain/entity/link_sort_order.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'link_sort_provider.g.dart';

const _kHomeLinkSortOrderKey = 'homeLinkSortOrder';

@Riverpod(keepAlive: true)
class LinkSortNotifier extends _$LinkSortNotifier {
  @override
  LinkSortOrder build() {
    try {
      if (!Hive.isBoxOpen('settings')) return LinkSortOrder.newest;
      final stored = Hive.box<String>(
        'settings',
      ).get(_kHomeLinkSortOrderKey);
      return switch (stored) {
        'oldest' => LinkSortOrder.oldest,
        _ => LinkSortOrder.newest,
      };
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'link sort preference read failed',
        error: error,
        stackTrace: stackTrace,
      );
      return LinkSortOrder.newest;
    }
  }

  Future<void> setSortOrder(LinkSortOrder order) async {
    if (state == order) return;

    state = order;
    try {
      await Hive.box<String>(
        'settings',
      ).put(_kHomeLinkSortOrderKey, order.name);
    } on Object catch (error, stackTrace) {
      appLogger.w(
        'link sort preference write failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
