import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the promise tracker dashboard', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('GHOSTING'), findsOneWidget);
    expect(find.text('ИНДЕКС ДОВЕРИЯ'), findsOneWidget);
    expect(find.text('Марк'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('record-broken-Марк')));
    await tester.pumpAndSettle();
    expect(find.text('9 срывов'), findsOneWidget);

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -450),
    );
    await tester.pumpAndSettle();
    expect(find.text('Инфляция обещаний'), findsOneWidget);
  });

  testWidgets('opens analytics and people tabs', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Аналитика').last);
    await tester.pumpAndSettle();
    expect(find.text('ЦИФРЫ НЕ ВРУТ'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -600),
    );
    await tester.pumpAndSettle();
    expect(find.text('Рейтинг доверия'), findsOneWidget);

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    expect(find.text('Добавить обещателя'), findsOneWidget);
    await tester.tap(find.text('Добавить обещателя'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Даша');
    await tester.enterText(find.byType(TextField).last, 'Позвоню завтра');
    await tester.tap(find.text('Добавить').last);
    await tester.pumpAndSettle();
    expect(find.text('Даша'), findsOneWidget);

    final menu = find.byType(PopupMenuButton<String>).last;
    await tester.ensureVisible(menu);
    await tester.pumpAndSettle();
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Дарья');
    await tester.tap(find.text('Сохранить').last);
    await tester.pumpAndSettle();
    expect(find.text('Дарья'), findsOneWidget);
  });

  testWidgets('profile avatar opens an editable profile', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Редактировать профиль'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Мария');
    await tester.tap(find.text('Сохранить').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Мария 👋'), findsOneWidget);
  });

  testWidgets('records a kept promise', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('record-kept-Марк')));
    await tester.pumpAndSettle();

    expect(find.text('27% доверия'), findsOneWidget);
  });

  testWidgets('fits a narrow phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('GHOSTING'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('uses a desktop sidebar on wide screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('PROMISE TRACKER'), findsNWidgets(2));
    expect(find.text('Обзор'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    await tester.binding.setSurfaceSize(null);
  });
}
