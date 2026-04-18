// dart format off
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class _MockLauncher extends Mock
    with MockPlatformInterfaceMixin
    implements UrlLauncherPlatform
{}

class _FakeOptions extends Fake implements LaunchOptions
{}

class _Capture extends StatelessWidget
{
  const _Capture(this.onBuild);

  final ValueSetter<BuildContext> onBuild;

  @override
  Widget build(BuildContext context)
  {
    onBuild(context);
    return const SizedBox.shrink();
  }
}

Widget _host(ValueSetter<BuildContext> onBuild)
{
  return MaterialApp(home: Scaffold(body: _Capture(onBuild)));
}

Future<BuildContext> _pumpCtx(WidgetTester tester) async
{
  late BuildContext captured;
  await tester.pumpWidget(_host((ctx) => captured = ctx));
  return captured;
}

Future<void> _emptyUrlCase(WidgetTester tester, _MockLauncher mock) async
{
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, '');
  await tester.pump();
  expect(result, isFalse);
  expect(find.text('Invalid link format'), findsOneWidget);
  verifyNever(() => mock.canLaunch(any()));
}

Future<void> _cannotLaunchCase(WidgetTester tester, _MockLauncher mock) async
{
  when(() => mock.canLaunch(any())).thenAnswer((_) async => false);
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, 'https://example.com');
  await tester.pump();
  expect(result, isFalse);
  expect(find.text('Cannot open link'), findsOneWidget);
  verifyNever(() => mock.launchUrl(any(), any()));
}

Future<void> _successCase(WidgetTester tester, _MockLauncher mock) async
{
  when(() => mock.canLaunch(any())).thenAnswer((_) async => true);
  when(() => mock.launchUrl(any(), any())).thenAnswer((_) async => true);
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, 'https://example.com');
  await tester.pump();
  expect(result, isTrue);
  expect(find.byType(SnackBar), findsNothing);
  verify(() => mock.launchUrl('https://example.com', any())).called(1);
}

Future<void> _exceptionCase(WidgetTester tester, _MockLauncher mock) async
{
  when(() => mock.canLaunch(any())).thenAnswer((_) async => true);
  when(() => mock.launchUrl(any(), any()))
      .thenThrow(PlatformException(code: 'LAUNCH_FAILED'));
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, 'https://example.com');
  await tester.pump();
  expect(result, isFalse);
  expect(find.text('Failed to open link'), findsOneWidget);
}

Future<void> _schemelessCase(WidgetTester tester, _MockLauncher mock) async
{
  when(() => mock.canLaunch(any())).thenAnswer((_) async => true);
  when(() => mock.launchUrl(any(), any())).thenAnswer((_) async => true);
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, 'youtu.be/dQw4w9WgXcQ');
  await tester.pump();
  expect(result, isTrue);
  expect(find.byType(SnackBar), findsNothing);
  verify(
    () => mock.launchUrl('https://youtu.be/dQw4w9WgXcQ', any()),
  ).called(1);
}

Future<void> _titlePlusUrlCase(WidgetTester tester, _MockLauncher mock) async
{
  when(() => mock.canLaunch(any())).thenAnswer((_) async => true);
  when(() => mock.launchUrl(any(), any())).thenAnswer((_) async => true);
  final context = await _pumpCtx(tester);
  const raw =
      '하네스 엔지니어링 - 50점짜리 Codex를 88점으로 만드는 법 - '
      'https://youtube.com/watch?v=p9mRnsx7yv4&si=LLAhSDDM4YQ_Xv4X';
  final result = await UrlLauncherHelper.launch(context, raw);
  await tester.pump();
  expect(result, isTrue);
  expect(find.byType(SnackBar), findsNothing);
  verify(
    () => mock.launchUrl(
      'https://youtube.com/watch?v=p9mRnsx7yv4&si=LLAhSDDM4YQ_Xv4X',
      any(),
    ),
  ).called(1);
}

Future<void> _garbageTitleCase(WidgetTester tester, _MockLauncher mock) async
{
  final context = await _pumpCtx(tester);
  final result = await UrlLauncherHelper.launch(context, '그냥 제목만 있는 텍스트');
  await tester.pump();
  expect(result, isFalse);
  expect(find.text('Invalid link format'), findsOneWidget);
  verifyNever(() => mock.canLaunch(any()));
}

void main()
{
  late _MockLauncher mock;

  setUpAll(() => registerFallbackValue(_FakeOptions()));

  setUp(()
  {
    mock = _MockLauncher();
    UrlLauncherPlatform.instance = mock;
  });

  testWidgets(
    'returns false + snackbar when URL is empty',
    (t) => _emptyUrlCase(t, mock),
  );

  testWidgets(
    'returns false + snackbar when canLaunch is false',
    (t) => _cannotLaunchCase(t, mock),
  );

  testWidgets(
    'returns true + no snackbar on successful launch',
    (t) => _successCase(t, mock),
  );

  testWidgets(
    'returns false + snackbar when launchUrl throws PlatformException',
    (t) => _exceptionCase(t, mock),
  );

  testWidgets(
    'prepends https:// scheme for scheme-less URL (e.g. youtu.be/xxx)',
    (t) => _schemelessCase(t, mock),
  );

  testWidgets(
    'extracts embedded URL from "title - URL" paste (YouTube share case)',
    (t) => _titlePlusUrlCase(t, mock),
  );

  testWidgets(
    'returns false + snackbar for text with no URL',
    (t) => _garbageTitleCase(t, mock),
  );
}
