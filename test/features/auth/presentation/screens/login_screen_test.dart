import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linknote/features/auth/domain/entity/auth_state_entity.dart';
import 'package:linknote/features/auth/presentation/provider/auth_provider.dart';
import 'package:linknote/features/auth/presentation/screens/login_screen.dart';

/// Auth notifier that stays in loading state — simulates initial session check.
class _UnauthenticatedAuth extends Auth {
  @override
  Future<AuthStateEntity> build() async {
    return const AuthStateEntity.unauthenticated();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    // no-op for validation tests
  }
}

/// Auth notifier that never completes — keeps loading indicator.
class _LoadingAuth extends Auth {
  @override
  Future<AuthStateEntity> build() {
    return Completer<AuthStateEntity>().future;
  }
}

void main() {
  Widget buildSubject({Auth Function()? authOverride}) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(authOverride ?? _UnauthenticatedAuth.new),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen', () {
    testWidgets('should render email and password fields', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should show validation messages when submitting empty form', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act — tap Sign In with empty fields
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('should show email validation when only password is filled', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'secret123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter email'), findsOneWidget);
      expect(find.text('Enter password'), findsNothing);
    });

    testWidgets('should show password validation when only email is filled', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Enter email'), findsNothing);
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('should show Sign In button and Create account link', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
    });

    testWidgets('should disable Sign In button when loading', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(buildSubject(authOverride: _LoadingAuth.new));
      await tester.pump();

      // Assert — the FilledButton should be disabled (onPressed == null)
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });
  });
}
