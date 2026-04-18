import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/link/presentation/provider/link_form_provider.dart';
import 'package:linknote/features/link/presentation/widgets/link_form_fields.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_sanitizer.dart';
import 'package:linknote/shared/widgets/primary_button_widget.dart';

class LinkAddScreen extends ConsumerStatefulWidget {
  const LinkAddScreen({super.key});

  @override
  ConsumerState<LinkAddScreen> createState() => _LinkAddScreenState();
}

class _LinkAddScreenState extends ConsumerState<LinkAddScreen> {
  final _urlController = TextEditingController();

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
          content: Text('URL extracted from pasted text'),
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
        title: const Text('Add Link'),
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
              label: 'Save Link',
              isLoading: isSubmitting,
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final success = await ref
                          .read(linkFormProvider(null).notifier)
                          .submit();
                      if (success && context.mounted) {
                        context
                          ..showSuccessSnackBar('Link saved')
                          ..pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
