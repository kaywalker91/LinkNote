import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/profile/presentation/provider/profile_provider.dart';
import 'package:linknote/shared/widgets/error_state_widget.dart';
import 'package:linknote/shared/widgets/skeleton/profile_header_skeleton.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('${Routes.profile}/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const ProfileHeaderSkeleton(),
        error: (error, _) => ErrorStateWidget(message: error.toString()),
        data: (profile) => ListView(
          children: [
            const SizedBox(height: AppSpacing.xxl),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profile.avatarUrl != null
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl == null
                        ? Text(
                            (profile.displayName ?? profile.email)
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(fontSize: 28),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    profile.displayName ?? profile.email,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    profile.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatChip(label: 'Links', count: profile.linkCount),
                  _StatChip(
                      label: 'Collections', count: profile.collectionCount),
                ],
              ),
            ),
            const Divider(height: AppSpacing.xxxl),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('${Routes.profile}/settings'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out',
                  style: TextStyle(color: Colors.red)),
              onTap: () =>
                  ref.read(authProvider.notifier).signOut(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      ],
    );
  }
}
