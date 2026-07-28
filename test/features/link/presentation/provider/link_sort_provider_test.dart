import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:linknote/features/link/domain/entity/link_sort_order.dart';
import 'package:linknote/features/link/presentation/provider/link_sort_provider.dart';

void main() {
  late Directory tempDirectory;
  late Box<String> settingsBox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'link_sort_provider_test_',
    );
    Hive.init(tempDirectory.path);
    settingsBox = await Hive.openBox<String>('settings');
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('defaults to newest when no preference is stored', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(linkSortProvider), LinkSortOrder.newest);
  });

  test('restores oldest from the settings box', () async {
    await settingsBox.put('homeLinkSortOrder', 'oldest');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(linkSortProvider), LinkSortOrder.oldest);
  });

  test('falls back to newest for an unknown stored value', () async {
    await settingsBox.put('homeLinkSortOrder', 'unsupported');
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(linkSortProvider), LinkSortOrder.newest);
  });

  test('persists a changed sort order across containers', () async {
    final firstContainer = ProviderContainer();
    await firstContainer
        .read(linkSortProvider.notifier)
        .setSortOrder(LinkSortOrder.oldest);
    firstContainer.dispose();

    final secondContainer = ProviderContainer();
    addTearDown(secondContainer.dispose);

    expect(settingsBox.get('homeLinkSortOrder'), 'oldest');
    expect(secondContainer.read(linkSortProvider), LinkSortOrder.oldest);
  });

  test('does not write when the selected order is unchanged', () async {
    final events = <BoxEvent>[];
    final subscription = settingsBox
        .watch(key: 'homeLinkSortOrder')
        .listen(events.add);
    addTearDown(subscription.cancel);
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(linkSortProvider.notifier)
        .setSortOrder(LinkSortOrder.newest);
    await Future<void>.delayed(Duration.zero);

    expect(events, isEmpty);
  });
}
