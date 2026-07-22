import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/features/link/presentation/widgets/link_form_fields.dart';
import 'package:linknote/features/share_intent/presentation/provider/pending_shared_url_provider.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_sanitizer.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';

class LinkAddScreen extends ConsumerStatefulWidget {
  const LinkAddScreen({this.initialUrl, super.key});

  /// Optional URL to seed the URL field with — used by the share-intent
  /// cold-start flow (`/links/new?prefill=...`).
  final String? initialUrl;

  @override
  ConsumerState<LinkAddScreen> createState() => _LinkAddScreenState();
}

class _LinkAddScreenState extends ConsumerState<LinkAddScreen> {
  final _urlController = TextEditingController();

  /// True when this screen was opened with a share-intent prefill URL.
  bool get _fromSharePrefill =>
      widget.initialUrl != null && widget.initialUrl!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    final seed = widget.initialUrl;
    if (seed != null && seed.isNotEmpty) {
      _urlController.text = seed;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Arrived via the share-intent prefill: consume the one-shot pending
        // URL here (deferred out of build — Riverpod forbids mutating a
        // provider during initState). The router redirect stays side-effect
        // free, so a later splash re-evaluation won't re-route here and a
        // subsequent login won't replay a stale share.
        ref.read(pendingSharedUrlProvider.notifier).consume();
        unawaited(_seedPrefillAndFetchOg(seed));
      });
    }
  }

  /// Waits for the form provider to leave loading, then injects [url] and
  /// kicks off a single OG fetch. Early `parseOgTags` while state is still
  /// `AsyncLoading` is a no-op (`state.value == null`).
  Future<void> _seedPrefillAndFetchOg(String url) async {
    await ref.read(linkFormProvider(null).future);
    if (!mounted) return;
    final notifier = ref.read(linkFormProvider(null).notifier)..updateUrl(url);
    await notifier.parseOgTags(url, fromShare: true);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Handles user input in the URL field.
  ///
  /// When a user pastes "title text - https://..." (common with share sheets),
  /// auto-extract the URL, replace the controller text, and — if the title
  /// field is still empty — copy the leading prose into the title field so
  /// no input is lost. A snackbar announces the auto-fix.
  void _handleUrlChanged(String value, LinkFormState? formState) {
    final notifier = ref.read(linkFormProvider(null).notifier);

    if (!UrlSanitizer.wouldAlter(value)) {
      notifier.updateUrl(value);
      return;
    }

    final extracted = UrlSanitizer.extract(value);
    if (extracted == null) {
      // No URL inside — keep raw value so the user can fix it.
      notifier.updateUrl(value);
      return;
    }

    // Prose before the extracted URL → candidate title.
    final idx = value.indexOf(extracted);
    final leading = idx > 0 ? value.substring(0, idx).trim() : '';
    final titleCandidate = _stripTrailingSeparators(leading);

    _urlController.value = TextEditingValue(
      text: extracted,
      selection: TextSelection.collapsed(offset: extracted.length),
    );
    notifier.updateUrl(extracted);

    final titleIsEmpty = (formState?.title ?? '').isEmpty;
    if (titleCandidate.isNotEmpty && titleIsEmpty) {
      // LinkFormFields mirrors state → controller; no direct controller write.
      notifier.updateTitle(titleCandidate);
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('붙여넣은 텍스트에서 URL을 추출했어요.'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  /// Strip trailing separator-ish characters from candidate title text
  /// (e.g. "하네스 엔지니어링 -" → "하네스 엔지니어링").
  static String _stripTrailingSeparators(String text) {
    var end = text.length;
    const seps = {0x2d, 0x7c, 0x3a, 0x2014, 0x2013, 0x00b7};
    while (end > 0) {
      final c = text.codeUnitAt(end - 1);
      if (c == 0x20 || seps.contains(c)) {
        end--;
      } else {
        break;
      }
    }
    return text.substring(0, end);
  }

  @override
  Widget build(BuildContext context) {
    final formAsync = ref.watch(linkFormProvider(null));
    final formState = formAsync.value;
    final isSubmitting = formState?.isSubmitting ?? false;
    final isParsingOg = formState?.isParsingOg ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('링크 추가'),
        actions: [
          if (isParsingOg)
            const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL *',
                hintText: 'https://',
                prefixIcon: Icon(Icons.link),
              ),
              onChanged: (v) => _handleUrlChanged(v, formState),
              onEditingComplete: () async {
                final url = _urlController.text.trim();
                if (url.isNotEmpty) {
                  await ref
                      .read(linkFormProvider(null).notifier)
                      .parseOgTags(url);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            const LinkFormFields(linkId: null),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButtonWidget(
              label: '저장',
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final success = await ref
                          .read(linkFormProvider(null).notifier)
                          .submit();
                      if (_fromSharePrefill) {
                        unawaited(
                          ref
                              .read(analyticsServiceProvider)
                              .logShareSaveResult(
                                success: success,
                              ),
                        );
                      }
                      if (success && context.mounted) {
                        context.showSuccessSnackBar('링크를 저장했어요.');
                        // A share cold-start reaches this screen via a redirect
                        // (empty stack beneath it), so there is nothing to pop —
                        // land on home. Manual/warm opens were pushed onto home
                        // and pop back normally.
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(Routes.home);
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
