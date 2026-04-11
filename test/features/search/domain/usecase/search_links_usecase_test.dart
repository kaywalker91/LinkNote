import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/domain/entity/search_filter_entity.dart';
import 'package:linknote/features/search/domain/repository/i_search_repository.dart';
import 'package:linknote/features/search/domain/usecase/search_links_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements ISearchRepository {}

void main() {
  late SearchLinksUsecase sut;
  late MockSearchRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const SearchFilterEntity());
  });

  setUp(() {
    mockRepository = MockSearchRepository();
    sut = SearchLinksUsecase(mockRepository);
  });

  const tQuery = 'flutter';

  final tLinks = [
    LinkEntity(
      id: '1',
      url: 'https://flutter.dev',
      title: 'Flutter',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    LinkEntity(
      id: '2',
      url: 'https://dart.dev',
      title: 'Dart',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  group('SearchLinksUsecase', () {
    test('should return list of links when search succeeds', () async {
      // Arrange
      when(
        () => mockRepository.searchLinks(any(), filter: any(named: 'filter')),
      ).thenAnswer((_) async => success(tLinks));

      // Act
      final result = await sut.call(tQuery);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tLinks));
      verify(
        () => mockRepository.searchLinks(tQuery, filter: any(named: 'filter')),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Failure when search fails', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Search failed');
      when(
        () => mockRepository.searchLinks(any(), filter: any(named: 'filter')),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call(tQuery);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
      verify(
        () => mockRepository.searchLinks(tQuery, filter: any(named: 'filter')),
      ).called(1);
    });
  });
}
