import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/auth/presentation/screens/login_screen.dart';
import 'package:linknote/features/auth/presentation/screens/signup_screen.dart';
import 'package:linknote/features/auth/presentation/screens/splash_screen.dart';
import 'package:linknote/features/collection/presentation/screens/collection_detail_screen.dart';
import 'package:linknote/features/collection/presentation/screens/collection_list_screen.dart';
import 'package:linknote/features/link/presentation/screens/home_screen.dart';
import 'package:linknote/features/link/presentation/screens/link_add_screen.dart';
import 'package:linknote/features/link/presentation/screens/link_detail_screen.dart';
import 'package:linknote/features/link/presentation/screens/link_edit_screen.dart';
import 'package:linknote/features/notification/presentation/screens/notification_screen.dart';
import 'package:linknote/features/search/presentation/screens/search_screen.dart';
import 'package:linknote/features/profile/presentation/screens/profile_screen.dart';
import 'package:linknote/features/profile/presentation/screens/settings_screen.dart';
import 'package:linknote/shared/widgets/app_scaffold_with_nav_bar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// Navigator keys for each shell branch
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _searchNavKey = GlobalKey<NavigatorState>(debugLabel: 'search');
final _collectionsNavKey = GlobalKey<NavigatorState>(debugLabel: 'collections');
final _notificationsNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'notifications');
final _profileNavKey = GlobalKey<NavigatorState>(debugLabel: 'profile');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final authNotifier = ref.watch(authProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.matchedLocation;

      // Still loading — stay on splash
      if (authState.isLoading) {
        if (location == Routes.splash) return null;
        return Routes.splash;
      }

      final isAuthenticated = authState.value is Authenticated;
      final isAuthRoute = location == Routes.login ||
          location == Routes.signup ||
          location == Routes.splash;

      if (!isAuthenticated && !isAuthRoute) return Routes.login;
      if (isAuthenticated && isAuthRoute) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      // Full-screen link routes accessible from any tab
      GoRoute(
        path: Routes.linkAdd,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LinkAddScreen(),
      ),
      GoRoute(
        path: Routes.linkDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LinkDetailScreen(
          linkId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.linkEdit,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => LinkEditScreen(
          linkId: state.pathParameters['id']!,
        ),
      ),

      // Shell with 5-tab bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) =>
            AppScaffoldWithNavBar(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                path: Routes.home,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavKey,
            routes: [
              GoRoute(
                path: Routes.search,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _collectionsNavKey,
            routes: [
              GoRoute(
                path: Routes.collections,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CollectionListScreen(),
                ),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => CollectionDetailScreen(
                      collectionId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _notificationsNavKey,
            routes: [
              GoRoute(
                path: Routes.notifications,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: NotificationScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                path: Routes.profile,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
