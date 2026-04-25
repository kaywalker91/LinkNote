import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/app/app.dart';

void main() {
  group('LinkNoteApp localization config', () {
    test('exposes Global Material/Widgets/Cupertino delegates', () {
      expect(
        LinkNoteApp.localizationsDelegates,
        containsAll(<LocalizationsDelegate<Object?>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ]),
      );
    });

    test('supports ko and en locales with ko as default', () {
      expect(LinkNoteApp.supportedLocales, contains(const Locale('ko')));
      expect(LinkNoteApp.supportedLocales, contains(const Locale('en')));
      expect(LinkNoteApp.defaultLocale, const Locale('ko'));
    });

    testWidgets(
      'MaterialLocalizations.of resolves ko without throwing',
      (tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: LinkNoteApp.localizationsDelegates,
            supportedLocales: LinkNoteApp.supportedLocales,
            locale: LinkNoteApp.defaultLocale,
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          MaterialLocalizations.of(capturedContext),
          isNotNull,
        );
        expect(
          Localizations.localeOf(capturedContext).languageCode,
          'ko',
        );
      },
    );
  });
}
