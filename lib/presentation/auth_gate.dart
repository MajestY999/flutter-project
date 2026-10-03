// Определяет, показывать экран входа или приложение для вошедшего пользователя.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'auth_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authenticatedBuilder, this.auth});

  final Widget Function(User user) authenticatedBuilder;
  final FirebaseAuth? auth;

  FirebaseAuth get _firebaseAuth => auth ?? FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _firebaseAuth.userChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не удалось проверить авторизацию: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) return AuthPage(auth: _firebaseAuth);
        return authenticatedBuilder(user);
      },
    );
  }
}
