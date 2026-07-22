import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/share_intent/data/android_share_extras.dart';
import 'package:linknote/features/share_intent/domain/service/share_payload_resolver.dart';

class _FakeExtrasReader extends AndroidShareExtrasReader {
  _FakeExtrasReader(this.extras);
  final AndroidShareExtras? extras;

  @override
  Future<AndroidShareExtras?> read() async => extras;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharePayloadResolver', () {
    test('uses plugin path when it already contains a URL', () async {
      final resolver = SharePayloadResolver(
        extrasReader: _FakeExtrasReader(null),
      );

      final url = await resolver.resolveUrl(
        'Video title - https://youtube.com/watch?v=abc',
      );

      expect(url, 'https://youtube.com/watch?v=abc');
    });

    test(
      'falls back to EXTRA_TEXT when plugin path is a local file (YouTube case)',
      () async {
        final resolver = SharePayloadResolver(
          extrasReader: _FakeExtrasReader(
            const AndroidShareExtras(
              text: '하네스 엔지니어링 - https://youtube.com/watch?v=p9mRnsx7yv4',
              subject: 'YouTube',
            ),
          ),
        );

        // Plugin delivered the thumbnail stream path, not the URL.
        final url = await resolver.resolveUrl(
          '/data/user/0/app.kaywalker.linknote/cache/thumb.jpg',
        );

        expect(url, 'https://youtube.com/watch?v=p9mRnsx7yv4');
      },
    );

    test('falls back to EXTRA_SUBJECT when text is empty', () async {
      final resolver = SharePayloadResolver(
        extrasReader: _FakeExtrasReader(
          const AndroidShareExtras(
            subject: 'https://youtu.be/shortid',
          ),
        ),
      );

      final url = await resolver.resolveUrl('/tmp/no-url-here.bin');
      expect(url, 'https://youtu.be/shortid');
    });

    test('returns null when neither plugin nor extras have a URL', () async {
      final resolver = SharePayloadResolver(
        extrasReader: _FakeExtrasReader(
          const AndroidShareExtras(text: 'no link at all'),
        ),
      );

      final url = await resolver.resolveUrl('/tmp/file.jpg');
      expect(url, isNull);
    });

    test('falls back to ClipData when text/subject carry no URL', () async {
      final resolver = SharePayloadResolver(
        extrasReader: _FakeExtrasReader(
          const AndroidShareExtras(
            text: 'shared from an app',
            clip0Uri: 'https://youtu.be/clipid',
          ),
        ),
      );

      final url = await resolver.resolveUrl('/tmp/thumb.jpg');
      expect(url, 'https://youtu.be/clipid');
    });

    test(
      'resolveFromExtras recovers URL when plugin delivered nothing',
      () async {
        final resolver = SharePayloadResolver(
          extrasReader: _FakeExtrasReader(null),
        );

        // pluginPath null (getInitialMedia empty) but EXTRA_TEXT has the URL.
        final url = resolver.resolveFromExtras(
          null,
          const AndroidShareExtras(text: 'https://youtu.be/nostream'),
        );
        expect(url, 'https://youtu.be/nostream');
      },
    );
  });

  group('AndroidShareExtrasReader channel', () {
    const channel = MethodChannel('app.kaywalker.linknote/share');

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('parses getShareExtras map from platform', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            expect(call.method, 'getShareExtras');
            return <String, dynamic>{
              'action': 'android.intent.action.SEND',
              'type': 'text/plain',
              'text': 'https://example.com/from-native',
              'subject': null,
              'htmlText': null,
              'clip0Text': null,
              'clip0Uri': 'https://example.com/clip',
            };
          });

      final extras = await AndroidShareExtrasReader().read();
      expect(extras?.text, 'https://example.com/from-native');
      expect(extras?.clip0Uri, 'https://example.com/clip');
      expect(extras?.urlCandidates.first, 'https://example.com/from-native');
    });
  });
}
