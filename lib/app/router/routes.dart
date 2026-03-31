abstract final class Routes {
  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';

  // Shell tabs
  static const String home = '/home';
  static const String search = '/search';
  static const String collections = '/collections';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Link routes (root navigator — accessible from any tab)
  static const String linkAdd = '/links/new';
  static const String linkDetail = '/links/:id';
  static const String linkEdit = '/links/:id/edit';

  // Nested routes
  static const String collectionDetail = '/collections/:id';
  static const String collectionNew = '/collections/new';
  static const String collectionEdit = '/collections/:id/edit';
  static const String settings = '/settings';

  static String linkDetailPath(String id) => '/links/$id';
  static String linkEditPath(String id) => '/links/$id/edit';
  static String collectionDetailPath(String id) => '/collections/$id';
  static String collectionEditPath(String id) => '/collections/$id/edit';
}
