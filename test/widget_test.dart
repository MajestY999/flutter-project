// Проверяет основные пользовательские сценарии и адаптивность экранов приложения.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/data/people_repository.dart';
import 'package:my_app/models/tracked_person.dart';
import 'package:my_app/app.dart';
import 'package:my_app/presentation/navigation.dart';

void main() {
  testWidgets('shows the promise tracker dashboard', (tester) async {
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
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
    expect(find.text('График обещаний'), findsOneWidget);
  });

  testWidgets('opens analytics and people tabs', (tester) async {
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
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
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Редактировать профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить имя'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Мария');
    await tester.tap(find.text('Сохранить').last);
    await tester.pumpAndSettle();

    expect(find.text('Мария'), findsOneWidget);
    expect(find.text('УРОВНИ ДОВЕРИЯ'), findsOneWidget);
    expect(find.text('УРОВНИ ДОВЕРИЯ'), findsOneWidget);
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Легенда обещаний'), findsOneWidget);
  });

  testWidgets('profile name editor remains usable on a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Редактировать профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить имя'));
    await tester.pumpAndSettle();

    expect(find.text('Ваш профиль'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    await tester.enterText(find.byType(TextField).last, 'Александра');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Александра'), findsOneWidget);
    expect(find.text('УРОВНИ ДОВЕРИЯ'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('profile can create a personal progress card', (tester) async {
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Редактировать профиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Создать мою карточку'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Я');
    await tester.tap(find.text('Добавить').last);
    await tester.pumpAndSettle();

    expect(find.text('ТВОЙ ТЕКУЩИЙ УРОВЕНЬ'), findsOneWidget);
    expect(find.text('Призрак обещаний'), findsNWidgets(2));
    expect(find.textContaining('Ещё 1 обещание сдержать'), findsOneWidget);
  });

  testWidgets('records a kept promise', (tester) async {
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('record-kept-Марк')));
    await tester.pumpAndSettle();

    expect(find.text('27% доверия'), findsOneWidget);
  });

  testWidgets('opens a promise card to show its details on mobile', (
    tester,
  ) async {
    const viewport = Size(320, 640);
    await tester.binding.setSurfaceSize(viewport);
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    final card = find.byKey(const ValueKey('person-card-mark'));
    await tester.ensureVisible(card);
    await tester.tap(card);
    await tester.pumpAndSettle();

    final dialog = find.byType(Dialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('Марк')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.text('«На следующей неделе точно»'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Сдержано')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Не сдержано')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('2')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('8')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('20%')),
      findsOneWidget,
    );

    final dialogRect = tester.getRect(dialog);
    expect(dialogRect.left, greaterThanOrEqualTo(0));
    expect(dialogRect.right, lessThanOrEqualTo(viewport.width));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Готово'));
    await tester.pumpAndSettle();
    expect(dialog, findsNothing);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('last promise actions stay above mobile browser controls', (
    tester,
  ) async {
    const viewport = Size(320, 640);
    await tester.binding.setSurfaceSize(viewport);
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    final peopleList = find.byKey(const PageStorageKey('people'));
    await tester.drag(peopleList, const Offset(0, -2000));
    await tester.pumpAndSettle();

    final lastAction = find.byKey(const ValueKey('record-broken-Илья'));
    final actionRect = tester.getRect(lastAction);
    expect(actionRect.bottom, lessThanOrEqualTo(viewport.height - 80));
    expect(tester.takeException(), isNull);

    await tester.tap(lastAction);
    await tester.pumpAndSettle();
    expect(find.text('5 срывов'), findsOneWidget);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('fits a narrow phone screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    expect(find.text('GHOSTING'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('adding a person fits a narrow mobile viewport', (tester) async {
    const viewport = Size(320, 640);
    await tester.binding.setSurfaceSize(viewport);
    final repository = _MemoryPeopleRepository();
    await tester.pumpWidget(MyApp(repository: repository));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'initial mobile dashboard');
    expect(find.text('Обзор'), findsOneWidget);
    final navigationSafeArea = tester.widget<SafeArea>(
      find.descendant(
        of: find.byType(BottomNavigation),
        matching: find.byType(SafeArea),
      ),
    );
    expect(navigationSafeArea.maintainBottomViewPadding, isTrue);

    await tester.tap(find.text('Люди').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'mobile people list');
    await tester.tap(find.text('Добавить обещателя'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'mobile add-person dialog');

    final dialogRect = tester.getRect(find.byType(Dialog));
    expect(dialogRect.left, greaterThanOrEqualTo(0));
    expect(dialogRect.right, lessThanOrEqualTo(viewport.width));

    final dialog = find.byType(Dialog);
    final dialogFields = find.descendant(
      of: dialog,
      matching: find.byType(TextField),
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();
    final keyboardDialogRect = tester.getRect(dialog);
    expect(keyboardDialogRect.left, greaterThanOrEqualTo(0));
    expect(keyboardDialogRect.right, lessThanOrEqualTo(viewport.width));
    expect(tester.takeException(), isNull, reason: 'mobile keyboard open');
    tester.view.resetViewInsets();
    await tester.pumpAndSettle();
    expect(find.text('Обзор'), findsOneWidget);
    final overviewTabRect = tester.getRect(find.text('Обзор'));
    expect(overviewTabRect.bottom, lessThanOrEqualTo(viewport.height));
    expect(overviewTabRect.bottom, greaterThan(viewport.height - 80));

    final nameField = tester.widget<TextField>(dialogFields.first);
    expect(nameField.autofocus, isFalse);
    expect(nameField.style?.fontSize, greaterThanOrEqualTo(16));
    await tester.enterText(dialogFields.first, 'Очень длинное имя');
    await tester.enterText(
      dialogFields.last,
      'Обещание, которое помещается на узком экране',
    );
    final addButton = find.descendant(
      of: dialog,
      matching: find.text('Добавить'),
    );
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(find.text('Обзор'), findsOneWidget);

    expect(
      repository._people?.any((person) => person.name == 'Очень длинное имя'),
      isTrue,
    );
    await tester.drag(
      find.byType(CustomScrollView).last,
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Очень длинное имя'), findsOneWidget);
    final addedPerson = repository._people!.last;
    final cardRect = tester.getRect(
      find.byKey(ValueKey('person-card-${addedPerson.id}')),
    );
    final actionRect = tester.getRect(
      find.byKey(ValueKey('record-broken-${addedPerson.name}')),
    );
    expect(cardRect.left, greaterThanOrEqualTo(0));
    expect(cardRect.right, lessThanOrEqualTo(viewport.width));
    expect(actionRect.left, greaterThanOrEqualTo(0));
    expect(actionRect.right, lessThanOrEqualTo(viewport.width));
    expect(tester.takeException(), isNull);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('uses a desktop sidebar on wide screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    expect(find.text('PROMISE TRACKER'), findsNWidgets(2));
    expect(find.text('Обзор'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('desktop brand mark returns to overview with pointer cursor', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    await tester.pumpWidget(MyApp(repository: _MemoryPeopleRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Аналитика').last);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<DesktopNavItem>(find.byType(DesktopNavItem))
          .first
          .selected,
      isFalse,
    );

    final brandTooltip = find.byTooltip('Вернуться к обзору');
    final brandInkWell = find.descendant(
      of: brandTooltip,
      matching: find.byType(InkWell),
    );
    expect(
      tester.widget<InkWell>(brandInkWell).mouseCursor,
      SystemMouseCursors.click,
    );
    await tester.tap(brandTooltip);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<DesktopNavItem>(find.byType(DesktopNavItem))
          .first
          .selected,
      isTrue,
    );

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('signed-in overview exposes logout and returns to login', (
    tester,
  ) async {
    var signedOut = false;
    await tester.pumpWidget(
      MaterialApp(
        home: GhostingHome(
          repository: _MemoryPeopleRepository(),
          accountEmail: 'person@example.com',
          onSignOut: () async {
            signedOut = true;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Выйти из аккаунта'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Выйти из аккаунта'));
    await tester.pumpAndSettle();
    expect(find.text('Выйти из аккаунта?'), findsOneWidget);
    await tester.tap(find.text('Выйти').last);
    await tester.pumpAndSettle();

    expect(signedOut, isTrue);
  });
}

class _MemoryPeopleRepository implements PeopleRepository {
  List<TrackedPerson>? _people;
  String? _profileName;

  @override
  Future<List<TrackedPerson>?> loadPeople() async => _people;

  @override
  Future<void> savePeople(List<TrackedPerson> people) async {
    _people = List.of(people);
  }

  @override
  Future<String?> loadProfileName() async => _profileName;

  @override
  Future<void> saveProfileName(String name) async {
    _profileName = name;
  }
}
