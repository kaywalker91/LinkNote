import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:linknote/app/router/routes.dart';
import 'package:linknote/core/services/analytics_service.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/widgets/offline_banner_widget.dart';

class AppScaffoldWithNavBar extends ConsumerWidget {
  const AppScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  static const List<String> destinationLabels = <String>[
    'Home',
    'Search',
    'Collections',
    'Profile',
  ];

  /// Branch root paths, parallel to [destinationLabels]. Used as `screen_view`
  /// names on tab switch — the root observer cannot see indexed-stack swaps.
  static const List<String> _branchRoutes = <String>[
    Routes.home,
    Routes.search,
    Routes.collections,
    Routes.profile,
  ];

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Links are mostly created through the share intent, so the Collections
    // tab trades the add-link FAB for the add-collection action that used to
    // live in the collection list top bar.
    final onCollections =
        _branchRoutes[navigationShell.currentIndex] == Routes.collections;

    return Scaffold(
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(child: navigationShell),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shell_fab',
        backgroundColor: context.palette.forest,
        foregroundColor: Colors.white,
        elevation: 6,
        tooltip: onCollections ? '컬렉션 추가' : '링크 추가',
        onPressed: () => context.push(
          onCollections ? Routes.collectionNew : Routes.linkAdd,
        ),
        child: Icon(
          onCollections ? Icons.create_new_folder_rounded : Icons.add_rounded,
          size: 24,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
            // Tab switches swap the indexed stack instead of pushing onto the
            // root navigator, so the FirebaseAnalyticsObserver never sees them.
            // Emit the screen_view manually here.
            unawaited(
              ref
                  .read(analyticsServiceProvider)
                  .logScreenView(_branchRoutes[index]),
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search_outlined),
              selectedIcon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.collections_bookmark_outlined),
              selectedIcon: Icon(Icons.collections_bookmark),
              label: 'Collections',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
