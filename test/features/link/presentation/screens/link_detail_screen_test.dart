import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/link_entity.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_detail_provider.dart';
import 'package:linknote/features/link/presentation/provider/link_list_provider.dart';
import 'package:linknote/features/link/presentation/screens/link_detail_screen.dart';
import 'package:linknote/shared/models/paginated_state.dart';

class _LoadingLinkDetail extends LinkDetail {
  @override
  Future<LinkEntity> build(String linkId) {
    return Completer<LinkEntity>().future;
  }
}

class _ErrorLinkDetail extends LinkDetail {
  @override
  Future<LinkEntity> build(String linkId) async {
    throw Exception('Failed to load');
  }

  @override
  Future<void> refresh() async {}
}

class _DataLinkDetail extends LinkDetail {
  final LinkEntity _link;
  _DataLinkDetail(this._link);

  @override
  Future<LinkEntity> build(String linkId) async => _link;

  @override
  Future<void> refresh() async {}

  @override
  Future<void> delete() async {}
}

class _StubLinkList extends LinkList {
  @override
  Future<PaginatedState<LinkEntity>> build() async =>
      const PaginatedState<LinkEntity>(items: []);

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> deleteLink(String id) async {}

  @override
  Future<void> toggleFavorite(String id) async {}
}

void main() {
  final tLink = LinkEntity(
    id: '1',
    url: 'https://flutter.dev',
    title: 'Flutter Documentation',
    description: 'Official Flutter docs',
    memo: 'Must read',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    tags: const [
      TagEntity(id: 't1', name: 'flutter', color: '#2196F3'),
    ],
    isFavorite: true,
  );

  group('LinkDetailScreen', () {
    testWidgets('should show skeleton when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(_LoadingLinkDetail.new),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pump();

      // Should be in loading state — no title displayed yet
      expect(find.text('Flutter Documentation'), findsNothing);
    });

    testWidgets('should show error state with retry', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(_ErrorLinkDetail.new),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);
    });

    testWidgets('should show link details when data is loaded',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(() => _DataLinkDetail(tLink)),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flutter Documentation'), findsOneWidget);
      expect(find.text('https://flutter.dev'), findsOneWidget);
      expect(find.text('Official Flutter docs'), findsOneWidget);
    });

    testWidgets('should show memo section when memo exists', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(() => _DataLinkDetail(tLink)),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notes'), findsOneWidget);
      expect(find.text('Must read'), findsOneWidget);
    });

    testWidgets('should show tags when present', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(() => _DataLinkDetail(tLink)),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('flutter'), findsOneWidget);
    });

    testWidgets('should show action buttons when data is loaded',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkDetailProvider.overrideWith(() => _DataLinkDetail(tLink)),
            linkListProvider.overrideWith(_StubLinkList.new),
          ],
          child: const MaterialApp(
            home: LinkDetailScreen(linkId: '1'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Favorite, edit, delete buttons
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });
  });
}
