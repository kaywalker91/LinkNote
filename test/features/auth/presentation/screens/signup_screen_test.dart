import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/auth/presentation/screens/signup_screen.dart';

class _IdleAuth extends Auth {
  @override
  Future<AuthStateEntity> build() async =>
      const AuthStateEntity.unauthenticated();

  @override
  Future<void> signUp({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  group('SignupScreen', () {
    testWidgets('should show app bar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should show email, password, and confirm password fields',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should show sign up button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show sign in link', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Already have an account? Sign In'),
        findsOneWidget,
      );
    });

    testWidgets('should show validation error when email is empty',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Enter valid password but no email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        '123456',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Enter email'), findsOneWidget);
    });

    testWidgets('should show validation error when password is too short',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        '123',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Min 6 characters'), findsOneWidget);
    });

    testWidgets('should show validation error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authProvider.overrideWith(_IdleAuth.new)],
          child: const MaterialApp(home: SignupScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123456',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'abcdef',
      );
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
