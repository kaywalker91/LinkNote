import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linknote/features/app_update/app_update_constants.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:linknote/features/app_update/presentation/provider/app_update_provider.dart';
import 'package:linknote/features/app_update/presentation/provider/update_dismissal_provider.dart';
import 'package:linknote/features/app_update/presentation/screen/force_update_screen.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';

/// Sits inside `MaterialApp.router`'s `builder`, wrapping the app subtree.
///
/// - `forced`   → replaces [child] entirely with [ForceUpdateScreen].
/// - `optional` → shows a non-blocking [MaterialBanner] via [messengerKey],
///   once per version, suppressed after the user dismisses that version.
/// - Re-checks the policy on app resume.
class UpdateGate extends ConsumerStatefulWidget {
  const UpdateGate({
    required this.messengerKey,
    required this.child,
    super.key,
  });

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  ConsumerState<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends ConsumerState<UpdateGate>
    with WidgetsBindingObserver {
  /// The version currently surfaced in the optional banner (null = none).
  int? _bannerVersion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(appUpdateProvider.notifier).recheck());
    }
  }

  void _syncBanner(UpdatePolicy? policy, int dismissed) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = widget.messengerKey.currentState;
      if (messenger == null) return;

      if (policy is OptionalUpdate && policy.latestVersionCode > dismissed) {
        if (_bannerVersion == policy.latestVersionCode) return;
        _bannerVersion = policy.latestVersionCode;
        messenger
          ..hideCurrentMaterialBanner()
          ..showMaterialBanner(_buildBanner(policy));
      } else if (_bannerVersion != null) {
        _bannerVersion = null;
        messenger.hideCurrentMaterialBanner();
      }
    });
  }

  MaterialBanner _buildBanner(OptionalUpdate policy) {
    final storeUrl = policy.storeUrl ?? AppUpdateConstants.defaultStoreUrl;
    return MaterialBanner(
      content: Text(policy.message ?? '새 버전을 사용할 수 있습니다.'),
      leading: const Icon(Icons.system_update_rounded),
      actions: [
        TextButton(
          onPressed: () {
            widget.messengerKey.currentState?.hideCurrentMaterialBanner();
            unawaited(
              ref
                  .read(updateDismissalProvider.notifier)
                  .dismiss(policy.latestVersionCode),
            );
          },
          child: const Text('나중에'),
        ),
        TextButton(
          onPressed: () {
            widget.messengerKey.currentState?.hideCurrentMaterialBanner();
            unawaited(UrlLauncherHelper.launch(context, storeUrl));
          },
          child: const Text('업데이트'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen(appUpdateProvider, (_, next) {
        _syncBanner(next.value, ref.read(updateDismissalProvider));
      })
      ..listen(updateDismissalProvider, (_, next) {
        _syncBanner(ref.read(appUpdateProvider).value, next);
      });

    final policy = ref.watch(appUpdateProvider).value;
    if (policy is ForcedUpdate) {
      return ForceUpdateScreen(policy: policy);
    }
    return widget.child;
  }
}
