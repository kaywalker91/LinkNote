import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/search/data/datasource/search_remote_datasource.dart';
import 'package:linknote/features/search/data/repository/search_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRemoteDataSource extends Mock
    implements SearchRemoteDataSource {}

void main() {
  late SearchRepositoryImpl sut;
  late MockSearchRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSearchRemoteDataSource();
    sut = SearchRepositoryImpl(mockDataSource);
  });

  final tLinks = [
    LinkEntity(
      id: 'link-1',
      url: 'https://example.com',
      title: 'Flutter Guide',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
  ];

  // ---------------------------------------------------------------------------
  // searchLinks
  // ---------------------------------------------------------------------------
  group('searchLinks', () {
    test('should return links on successful search', () async {
      // Arrange
      when(
        () => mockDataSource.searchLinks(any()),
      ).thenAnswer((_) async => success(tLinks));

      // Act
      final result = await sut.searchLinks('flutter');

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.data, equals(tLinks));
      verify(() => mockDataSource.searchLinks('flutter')).called(1);
    });

    test('should return failure on error', () async {
      // Arrange
      const tFailure = Failure.server(message: 'Search failed');
      when(
        () => mockDataSource.searchLinks(any()),
      ).thenAnswer((_) async => error(tFailure));

      // Act
      final result = await sut.searchLinks('flutter');

      // Assert
      expect(result.isFailure, isTrue);
    });
  });
}
