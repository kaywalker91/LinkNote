import 'package:flutter/material.dart';
import 'package:linknote/features/app_update/app_update_constants.dart';
import 'package:linknote/features/app_update/domain/entity/update_policy.dart';
import 'package:linknote/shared/utils/url_launcher_helper.dart';

/// Full-screen, non-dismissible gate shown when the running version is below the
/// minimum supported. Replaces the entire app subtree — there is no way past it
/// except installing the update and relaunching.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({required this.policy, super.key});

  final ForcedUpdate policy;

  static const String _defaultMessage = '보안 및 안정성을 위해 최신 버전으로 업데이트해야 합니다.';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeUrl = policy.storeUrl ?? AppUpdateConstants.defaultStoreUrl;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.system_update_rounded,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '업데이트가 필요합니다',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    policy.message ?? _defaultMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () =>
                          UrlLauncherHelper.launch(context, storeUrl),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Text('Play 스토어에서 업데이트'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
