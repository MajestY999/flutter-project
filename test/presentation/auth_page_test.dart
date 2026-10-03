import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/presentation/auth_page.dart';

void main() {
  testWidgets('registration asks for a display name on a mobile viewport', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await tester.pumpWidget(const MaterialApp(home: AuthPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Нет аккаунта? Зарегистрироваться'));
    await tester.pumpAndSettle();

    expect(find.text('Создать аккаунт'), findsOneWidget);
    expect(find.text('Ваше имя'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Зарегистрироваться'));
    await tester.tap(find.text('Зарегистрироваться'));
    await tester.pumpAndSettle();
    expect(find.text('Напишите, как к вам обращаться.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });
}
