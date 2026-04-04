import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/repository/i_link_repository.dart';
import 'package:linknote/features/link/domain/usecase/fetch_links_usecase.dart';
import 'package:linknote/shared/models/paginated_state.dart';
import 'package:mocktail/mocktail.dart';

class MockLinkRepository extends Mock implements ILinkRepository {}

void main() {
  late FetchLinksUsecase sut;
  late MockLinkRepository mockRepository;

  setUp(() {
    mockRepository = MockLinkRepository();
    sut = FetchLinksUsecase(mockRepository);
  });

  final tLinks = [
    LinkEntity(
      id: '1',
      url: 'https://example.com/1',
      title: 'Link 1',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    LinkEntity(
      id: '2',
      url: 'https://example.com/2',
      title: 'Link 2',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  group('FetchLinksUsecase', () {
    test('should return paginated links when repository succeeds', () async {
      // Arrange
      final tState = PaginatedState<LinkEntity>(
        items: tLinks,
        hasMore: true,
        nextCursor: '2026-01-01T00:00:00.000Z',
      );
      when(
        () => mockRepository.getLinks(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
          favoritesOnly: any(named: 'favoritesOnly'),
        ),
      ).thenAnswer((_) async => success(tState));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, equals(tLinks));
      expect(result.data!.hasMore, isTrue);
      verify(
        () => mockRepository.getLinks(
          cursor: null,
          pageSize: 20,
          favoritesOnly: false,
        ),
      ).called(1);
    });

    test('should return empty list when no links exist', () async {
      // Arrange
      const tEmptyState = PaginatedState<LinkEntity>(items: []);
      when(
        () => mockRepository.getLinks(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
          favoritesOnly: any(named: 'favoritesOnly'),
        ),
      ).thenAnswer((_) async => success(tEmptyState));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data!.items, isEmpty);
      expect(result.data!.hasMore, isFalse);
    });

    test('should return Failure when repository fails', () async {
      // Arrange
      const tFailure = Failure.network(message: 'No connection');
      when(
        () => mockRepository.getLinks(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
          favoritesOnly: any(named: 'favoritesOnly'),
        ),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.call();

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(tFailure));
    });

    test('should pass cursor and favoritesOnly parameters correctly', () async {
      // Arrange
      const tState = PaginatedState<LinkEntity>(items: []);
      when(
        () => mockRepository.getLinks(
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
          favoritesOnly: any(named: 'favoritesOnly'),
        ),
      ).thenAnswer((_) async => success(tState));

      // Act
      await sut.call(cursor: 'some-cursor', pageSize: 10, favoritesOnly: true);

      // Assert
      verify(
        () => mockRepository.getLinks(
          cursor: 'some-cursor',
          pageSize: 10,
          favoritesOnly: true,
        ),
      ).called(1);
    });
  });
}
