import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/toggle_favorite_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/search/domain/usecase/search_links_usecase.dart';
import 'package:linknote/features/search/presentation/provider/search_di_providers.dart';
import 'package:linknote/features/search/presentation/provider/search_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchLinksUsecase extends Mock implements SearchLinksUsecase {}

class MockToggleFavoriteUsecase extends Mock implements ToggleFavoriteUsecase {}

final _tLink = LinkEntity(
  id: 'link-1',
  url: 'https://example.com',
  title: 'Example',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  late MockSearchLinksUsecase mockSearch;
  late MockToggleFavoriteUsecase mockToggle;
  late ProviderContainer container;
  late ProviderSubscription<Object?> sub;

  setUp(() {
    mockSearch = MockSearchLinksUsecase();
    mockToggle = MockToggleFavoriteUsecase();
    container = ProviderContainer(
      overrides: [
        searchLinksUsecaseProvider.overrideWithValue(mockSearch),
        toggleFavoriteUsecaseProvider.overrideWithValue(mockToggle),
      ],
    );
    sub = container.listen(
      searchProvider,
      (_, __) {},
    );
  });

  tearDown(() {
    sub.close();
    container.dispose();
  });

  Future<Search> buildWithResults() async {
    when(
      () => mockSearch.call(any()),
    ).thenAnswer((_) async => success([_tLink]));
    final notifier = container.read(searchProvider.notifier)
      ..updateQuery('example');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return notifier;
  }

  test(
    'toggleFavorite: optimistically sets isFavorite to true',
    () async {
      when(
        () => mockToggle.call('link-1', isFavorite: true),
      ).thenAnswer((_) async => success(_tLink.copyWith(isFavorite: true)));
      final notifier = await buildWithResults();

      await notifier.toggleFavorite('link-1');

      final link = container
          .read(searchProvider)
          .results
          .firstWhere((l) => l.id == 'link-1');
      expect(link.isFavorite, isTrue);
    },
  );

  test(
    'toggleFavorite: rolls back isFavorite on usecase failure',
    () async {
      when(() => mockToggle.call('link-1', isFavorite: true)).thenAnswer(
        (_) async => error(const Failure.server(message: 'Toggle failed')),
      );
      final notifier = await buildWithResults();

      await notifier.toggleFavorite('link-1');

      final link = container
          .read(searchProvider)
          .results
          .firstWhere((l) => l.id == 'link-1');
      expect(link.isFavorite, isFalse);
    },
  );
}
