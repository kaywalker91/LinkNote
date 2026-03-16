import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    // TODO(linknote): Add auth redirect logic.
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _PlaceholderScreen(title: 'Home'),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const _PlaceholderScreen(title: 'Login'),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
      ),
      GoRoute(
        path: Routes.profile,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Profile'),
      ),
      GoRoute(
        path: Routes.linkDetail,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Link Detail'),
      ),
      GoRoute(
        path: Routes.collection,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Collection'),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) =>
            const _PlaceholderScreen(title: 'Settings'),
      ),
    ],
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'LinkNote $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
