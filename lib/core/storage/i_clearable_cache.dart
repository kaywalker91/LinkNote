/// Interface for local caches that can be cleared on sign-out.
// ignore: one_member_abstracts
abstract interface class IClearableCache {
  Future<void> clearAll();
}
