import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/profile/domain/entity/user_profile_entity.dart';
import 'package:linknote/features/profile/presentation/provider/profile_provider.dart';
import 'package:linknote/features/profile/presentation/screens/profile_screen.dart';

class _LoadingProfile extends Profile {
  @override
  Future<UserProfileEntity> build() {
    return Completer<UserProfileEntity>().future;
  }
}

class _ErrorProfile extends Profile {
  @override
  Future<UserProfileEntity> build() async {
    throw Exception('Failed to load profile');
  }
}

class _DataProfile extends Profile {
  final UserProfileEntity _profile;
  _DataProfile(this._profile);

  @override
  Future<UserProfileEntity> build() async => _profile;

  @override
  Future<void> updateProfile({String? displayName, String? avatarUrl}) async {}

  @override
  Future<void> refresh() async {}
}

class _StubAuth extends Auth {
  @override
  Future<AuthStateEntity> build() async =>
      const AuthStateEntity.unauthenticated();

  @override
  Future<void> signOut() async {}
}

void main() {
  const tProfile = UserProfileEntity(
    id: 'u1',
    email: 'test@example.com',
    displayName: 'Test User',
    linkCount: 42,
    collectionCount: 5,
  );

  group('ProfileScreen', () {
    testWidgets('should show app bar with title and settings icon',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(_LoadingProfile.new),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
    });

    testWidgets('should show error state when profile fails to load',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(_ErrorProfile.new),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('오류가 발생했습니다'), findsOneWidget);
    });

    testWidgets('should show profile info when data is loaded',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => _DataProfile(tProfile)),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should show link and collection counts', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => _DataProfile(tProfile)),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('Collections'), findsOneWidget);
    });

    testWidgets('should show first letter avatar when no avatar url',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => _DataProfile(tProfile)),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('T'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should show settings and sign out options', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => _DataProfile(tProfile)),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('should show email as name when displayName is null',
        (tester) async {
      const profileNoName = UserProfileEntity(
        id: 'u1',
        email: 'user@example.com',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileProvider.overrideWith(() => _DataProfile(profileNoName)),
            authProvider.overrideWith(_StubAuth.new),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Email shown as name and also as subtitle
      expect(find.text('user@example.com'), findsNWidgets(2));
    });
  });
}
