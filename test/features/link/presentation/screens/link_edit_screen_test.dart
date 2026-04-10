import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/link/domain/entity/tag_entity.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/features/link/presentation/screens/link_edit_screen.dart';

class _LoadingLinkForm extends LinkForm {
  @override
  Future<LinkFormState> build(String? linkId) {
    return Completer<LinkFormState>().future;
  }
}

class _DataLinkForm extends LinkForm {
  final LinkFormState _state;
  _DataLinkForm(this._state);

  @override
  Future<LinkFormState> build(String? linkId) async => _state;

  @override
  void updateTitle(String title) {}

  @override
  void updateDescription(String description) {}

  @override
  void updateMemo(String memo) {}

  @override
  void addTag(TagEntity tag) {}

  @override
  void removeTag(String tagId) {}

  @override
  void toggleFavorite() {}

  @override
  Future<bool> submit() async => true;
}

void main() {
  group('LinkEditScreen', () {
    testWidgets('should show app bar with Edit Link title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(_LoadingLinkForm.new),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pump();

      expect(find.text('Edit Link'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(_LoadingLinkForm.new),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show form fields when data is loaded', (tester) async {
      const formState = LinkFormState(
        url: 'https://flutter.dev',
        title: 'Flutter Dev',
        description: 'Official Flutter docs',
        memo: 'Read later',
        tags: [TagEntity(id: 't1', name: 'flutter', color: '#2196F3')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(() => _DataLinkForm(formState)),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('https://flutter.dev'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets('should show tags when present', (tester) async {
      const formState = LinkFormState(
        url: 'https://flutter.dev',
        title: 'Flutter Dev',
        tags: [TagEntity(id: 't1', name: 'flutter', color: '#2196F3')],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(() => _DataLinkForm(formState)),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('flutter'), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });

    testWidgets('should show Update Link button', (tester) async {
      const formState = LinkFormState(
        url: 'https://flutter.dev',
        title: 'Flutter',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(() => _DataLinkForm(formState)),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Update Link'), findsOneWidget);
    });

    testWidgets('should show favorite switch', (tester) async {
      const formState = LinkFormState(
        url: 'https://flutter.dev',
        title: 'Flutter',
        isFavorite: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            linkFormProvider.overrideWith(() => _DataLinkForm(formState)),
          ],
          child: const MaterialApp(home: LinkEditScreen(linkId: '1')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Favorite'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });
  });
}
