import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/core/error/failure.dart';
import 'package:linknote/core/error/result.dart';
import 'package:linknote/core/services/og_tag_service.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/usecase/create_link_usecase.dart';
import 'package:linknote/features/link/domain/usecase/get_link_detail_usecase.dart';
import 'package:linknote/features/link/domain/usecase/update_link_usecase.dart';
import 'package:linknote/features/link/presentation/provider/link_di_providers.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockCreateLinkUsecase extends Mock implements CreateLinkUsecase {}

class MockUpdateLinkUsecase extends Mock implements UpdateLinkUsecase {}

class MockGetLinkDetailUsecase extends Mock implements GetLinkDetailUsecase {}

class MockOgTagService extends Mock implements OgTagService {}

class FakeLinkEntity extends Fake implements LinkEntity {}

void main() {
  late MockCreateLinkUsecase mockCreate;
  late MockUpdateLinkUsecase mockUpdate;
  late MockGetLinkDetailUsecase mockGetDetail;
  late MockOgTagService mockOgService;

  final tNow = DateTime(2026);
  final tExistingLink = LinkEntity(
    id: 'link-1',
    url: 'https://example.com',
    title: 'Existing Link',
    description: 'A description',
    collectionId: 'col-1',
    createdAt: tNow,
    updatedAt: tNow,
    isFavorite: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeLinkEntity());
  });

  setUp(() {
    mockCreate = MockCreateLinkUsecase();
    mockUpdate = MockUpdateLinkUsecase();
    mockGetDetail = MockGetLinkDetailUsecase();
    mockOgService = MockOgTagService();
  });

  ProviderContainer createContainer({String? linkId}) {
    if (linkId != null) {
      when(
        () => mockGetDetail.call(linkId),
      ).thenAnswer((_) async => success(tExistingLink));
    }
    return ProviderContainer(
      overrides: [
        createLinkUsecaseProvider.overrideWithValue(mockCreate),
        updateLinkUsecaseProvider.overrideWithValue(mockUpdate),
        getLinkDetailUsecaseProvider.overrideWithValue(mockGetDetail),
        ogTagServiceProvider.overrideWithValue(mockOgService),
      ],
    );
  }

  group('LinkForm', () {
    group('build', () {
      test(
        'should return empty state when linkId is null (create mode)',
        () async {
          final container = createContainer();
          addTearDown(container.dispose);

          final state = await container.read(linkFormProvider(null).future);

          expect(state.url, isEmpty);
          expect(state.title, isEmpty);
          expect(state.collectionId, isNull);
          expect(state.originalCreatedAt, isNull);
        },
      );

      test('should populate state from existing link (edit mode)', () async {
        final container = createContainer(linkId: 'link-1');
        addTearDown(container.dispose);

        final state = await container.read(linkFormProvider('link-1').future);

        expect(state.url, 'https://example.com');
        expect(state.title, 'Existing Link');
        expect(state.description, 'A description');
        expect(state.collectionId, 'col-1');
        expect(state.isFavorite, isTrue);
        expect(state.originalCreatedAt, tNow);
      });
    });

    group('submit', () {
      test('should call createLinkUsecase when linkId is null', () async {
        when(() => mockCreate.call(any())).thenAnswer(
          (_) async => success(tExistingLink),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkFormProvider(null).future);

        // Set required fields
        container
            .read(linkFormProvider(null).notifier)
            .updateUrl(
              'https://new.com',
            );
        container
            .read(linkFormProvider(null).notifier)
            .updateTitle(
              'New Link',
            );

        // Act
        final result = await container
            .read(linkFormProvider(null).notifier)
            .submit();

        // Assert
        expect(result, isTrue);
        verify(() => mockCreate.call(any())).called(1);
        verifyNever(() => mockUpdate.call(any()));
      });

      test('should call updateLinkUsecase when linkId is not null', () async {
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => success(tExistingLink),
        );

        final container = createContainer(linkId: 'link-1');
        addTearDown(container.dispose);
        await container.read(linkFormProvider('link-1').future);

        // Act
        final result = await container
            .read(linkFormProvider('link-1').notifier)
            .submit();

        // Assert
        expect(result, isTrue);
        verify(() => mockUpdate.call(any())).called(1);
        verifyNever(() => mockCreate.call(any()));
      });

      test('should return false when url is empty', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkFormProvider(null).future);

        container.read(linkFormProvider(null).notifier).updateTitle('A title');

        final result = await container
            .read(linkFormProvider(null).notifier)
            .submit();

        expect(result, isFalse);
      });

      test('should return false on usecase failure', () async {
        when(() => mockCreate.call(any())).thenAnswer(
          (_) async => error(const Failure.server(message: 'Failed')),
        );

        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkFormProvider(null).future);

        container.read(linkFormProvider(null).notifier)
          ..updateUrl('https://x.com')
          ..updateTitle('Title');

        final result = await container
            .read(linkFormProvider(null).notifier)
            .submit();

        expect(result, isFalse);
        final state = container.read(linkFormProvider(null)).value!;
        expect(state.errorMessage, isNotNull);
      });
    });

    group('updateCollectionId', () {
      test('should update collectionId in state', () async {
        final container = createContainer();
        addTearDown(container.dispose);
        await container.read(linkFormProvider(null).future);

        container
            .read(linkFormProvider(null).notifier)
            .updateCollectionId('col-2');

        final state = container.read(linkFormProvider(null)).value!;
        expect(state.collectionId, 'col-2');
      });

      test('should allow setting collectionId to null', () async {
        final container = createContainer(linkId: 'link-1');
        addTearDown(container.dispose);
        await container.read(linkFormProvider('link-1').future);

        container
            .read(linkFormProvider('link-1').notifier)
            .updateCollectionId(null);

        final state = container.read(linkFormProvider('link-1')).value!;
        expect(state.collectionId, isNull);
      });
    });

    group('originalCreatedAt preservation', () {
      test('should use originalCreatedAt in edit mode submit', () async {
        when(() => mockUpdate.call(any())).thenAnswer(
          (_) async => success(tExistingLink),
        );

        final container = createContainer(linkId: 'link-1');
        addTearDown(container.dispose);
        await container.read(linkFormProvider('link-1').future);

        await container.read(linkFormProvider('link-1').notifier).submit();

        final captured = verify(() => mockUpdate.call(captureAny())).captured;
        final entity = captured.first as LinkEntity;
        expect(entity.createdAt, tNow);
      });
    });
  });
}
