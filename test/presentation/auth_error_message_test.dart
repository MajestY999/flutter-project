import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/presentation/auth_error_message.dart';

void main() {
  test('explains how to resolve missing Firebase Auth configuration', () {
    final message = authErrorMessage(
      FirebaseAuthException(
        code: 'configuration-not-found',
        message: 'CONFIGURATION_NOT_FOUND',
      ),
    );

    expect(message, contains('Firebase Console'));
    expect(message, contains('Authentication → Get started'));
    expect(message, contains('Email/Password'));
  });

  test('explains when Email and Password provider is disabled', () {
    final message = authErrorMessage(
      FirebaseAuthException(code: 'operation-not-allowed'),
    );

    expect(message, contains('Email/Password'));
    expect(message, contains('Sign-in method'));
  });
}
