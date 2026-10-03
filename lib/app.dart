// Собирает приложение, управляет вкладками и связывает интерфейс с состоянием.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'data/people_repository.dart';
import 'models/tracked_person.dart';
import 'presentation/analytics_page.dart';
import 'presentation/auth_gate.dart';
import 'presentation/dialogs.dart';
import 'presentation/navigation.dart';
import 'presentation/overview_widgets.dart';
import 'presentation/people_page.dart';
import 'presentation/person_details_dialog.dart';
import 'presentation/profile_page.dart';
import 'theme/app_colors.dart';
import 'state/ghosting_controller.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.repository});

  final PeopleRepository? repository;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF9D84FF);
    return MaterialApp(
      title: 'Ghosting Counter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceRaised,
          contentTextStyle: const TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: repository == null
          ? AuthGate(
              authenticatedBuilder: (user) => GhostingHome(
                key: ValueKey(user.uid),
                repository: SqlitePeopleRepository(
                  accountId: user.uid,
                  showSampleDataWhenEmpty: false,
                ),
                initialProfileName: user.displayName?.trim().isNotEmpty == true
                    ? user.displayName!.trim()
                    : user.email?.split('@').first ?? 'Пользователь',
                accountEmail: user.email,
                onSignOut: FirebaseAuth.instance.signOut,
                onAccountNameChanged: (name) async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) await user.updateDisplayName(name);
                },
              ),
            )
          : GhostingHome(repository: repository!),
    );
  }
}

class GhostingHome extends StatefulWidget {
  const GhostingHome({
    super.key,
    required this.repository,
    this.initialProfileName = 'Алексей',
    this.accountEmail,
    this.onSignOut,
    this.onAccountNameChanged,
  });

  final PeopleRepository repository;
  final String initialProfileName;
  final String? accountEmail;
  final Future<void> Function()? onSignOut;
  final Future<void> Function(String name)? onAccountNameChanged;

  @override
  State<GhostingHome> createState() => _GhostingHomeState();
}

class _GhostingHomeState extends State<GhostingHome> {
  late final GhostingController _controller;
  int _selectedTab = 0;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = GhostingController(
      widget.repository,
      initialProfileName: widget.initialProfileName,
    );
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() => _loadError = null);
    try {
      await _controller.load();
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      );
  }

  Future<void> _runAction(
    Future<void> action, {
    required String successMessage,
  }) async {
    try {
      await action;
      if (mounted) _showMessage(successMessage);
    } catch (error) {
      if (mounted) _showMessage('Не удалось сохранить: $error');
    }
  }

  Future<void> _editPerson([
    TrackedPerson? person,
    bool initiallySelf = false,
  ]) async {
    final result = await showDialog<PersonFormData>(
      context: context,
      builder: (context) =>
          PersonDialog(initialPerson: person, initiallySelf: initiallySelf),
    );
    if (result == null) return;
    if (person == null) {
      await _runAction(
        _controller.addPerson(
          name: result.name,
          promise: result.promise,
          isSelf: result.isSelf,
          broken: result.broken,
          kept: result.kept,
        ),
        successMessage: '${result.name} добавлен(а) в список.',
      );
    } else {
      await _runAction(
        _controller.updatePerson(
          id: person.id,
          name: result.name,
          promise: result.promise,
          isSelf: result.isSelf,
          broken: result.broken,
          kept: result.kept,
        ),
        successMessage: 'Карточка ${result.name} обновлена.',
      );
    }
  }

  Future<void> _showPersonDetails(TrackedPerson person) {
    return showDialog<void>(
      context: context,
      builder: (context) => PersonDetailsDialog(person: person),
    );
  }

  Future<void> _editProfile() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => ProfileDialog(initialName: _controller.profileName),
    );
    if (name == null || name.trim().isEmpty) return;
    await _runAction(
      _saveProfileName(name.trim()),
      successMessage: 'Профиль обновлён.',
    );
  }

  Future<void> _saveProfileName(String name) async {
    await _controller.updateProfileName(name);
    await widget.onAccountNameChanged?.call(name);
  }

  Future<void> _signOut() async {
    final signOut = widget.onSignOut;
    if (signOut == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из аккаунта?'),
        content: const Text(
          'Локальные карточки останутся сохранены в аккаунте на этом устройстве.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await signOut();
    } catch (error) {
      if (mounted) _showMessage('Не удалось выйти из аккаунта: $error');
    }
  }

  void _openProfile() => setState(() => _selectedTab = 3);

  Future<void> _createOwnProfileCard() => _editPerson(null, true);

  Future<void> _recordBroken(String id) => _runAction(
    _controller.recordBroken(id),
    successMessage: 'Срыв записан. Доверие стало чуть призрачнее 👻',
  );

  Future<void> _recordKept(String id) => _runAction(
    _controller.recordKept(id),
    successMessage: 'Обещание сдержано. Доверие восстановлено ✨',
  );

  Future<void> _deletePerson(String id) async {
    final person = _controller.people.firstWhere((item) => item.id == id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить карточку?'),
        content: Text(
          'Записи ${person.name} будут удалены с этого устройства.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _runAction(
      _controller.deletePerson(id),
      successMessage: '${person.name} удалён(а).',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        if (_loadError != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: Color(0xFFFF9B85),
                      size: 36,
                    ),
                    const SizedBox(height: 12),
                    const Text('Не удалось открыть данные'),
                    const SizedBox(height: 8),
                    Text(
                      _loadError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final ownCards = _controller.people.where((person) => person.isSelf);
        final ownCard = ownCards.isEmpty ? null : ownCards.first;
        final pages = [
          OverviewTab(
            people: _controller.people,
            profileName: _controller.profileName,
            trust: _controller.trust,
            totalBroken: _controller.totalBroken,
            onAddPerson: _editPerson,
            onEditProfile: _openProfile,
            onRecordBroken: _recordBroken,
            onRecordKept: _recordKept,
            onOpenPerson: _showPersonDetails,
            onViewAnalytics: () => setState(() => _selectedTab = 1),
            onViewPeople: () => setState(() => _selectedTab = 2),
            onSignOut: widget.onSignOut == null ? null : _signOut,
          ),
          AnalyticsTab(
            people: _controller.people,
            trust: _controller.trust,
            totalBroken: _controller.totalBroken,
            totalKept: _controller.totalKept,
          ),
          PeopleTab(
            people: _controller.people,
            onAddPerson: _editPerson,
            onEditPerson: _editPerson,
            onOpenPerson: _showPersonDetails,
            onRecordBroken: _recordBroken,
            onRecordKept: _recordKept,
            onDeletePerson: _deletePerson,
          ),
          ProfileTab(
            name: _controller.profileName,
            person: ownCard,
            onBack: () => setState(() => _selectedTab = 0),
            onEditName: _editProfile,
            onCreateOwnCard: _createOwnProfileCard,
            accountEmail: widget.accountEmail,
            onSignOut: widget.onSignOut == null ? null : _signOut,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 850;
            final content = _controller.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.lime),
                  )
                : IndexedStack(index: _selectedTab, children: pages);

            return Scaffold(
              body: SafeArea(
                bottom: !isDesktop,
                child: isDesktop
                    ? Row(
                        children: [
                          DesktopNavigation(
                            selectedIndex: _selectedTab,
                            onSelected: (index) =>
                                setState(() => _selectedTab = index),
                            onProfile: _openProfile,
                            profileName: _controller.profileName,
                          ),
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1120,
                                ),
                                child: content,
                              ),
                            ),
                          ),
                        ],
                      )
                    : content,
              ),
              bottomNavigationBar: isDesktop
                  ? null
                  : BottomNavigation(
                      selectedIndex: _selectedTab,
                      onSelected: (index) =>
                          setState(() => _selectedTab = index),
                    ),
            );
          },
        );
      },
    );
  }
}

class DesktopNavigation extends StatelessWidget {
  const DesktopNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onProfile,
    required this.profileName,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onProfile;
  final String profileName;

  static const _items = [
    (Icons.grid_view_rounded, 'Обзор'),
    (Icons.insert_chart_outlined_rounded, 'Аналитика'),
    (Icons.people_alt_outlined, 'Люди'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF121117),
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 16, 30),
            child: Tooltip(
              message: 'Вернуться к обзору',
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(13),
                onTap: () => onSelected(0),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: BrandMark(),
                  ),
                ),
              ),
            ),
          ),
          for (var i = 0; i < _items.length; i++)
            DesktopNavItem(
              icon: _items[i].$1,
              label: _items[i].$2,
              selected: selectedIndex == i,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: onProfile,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ProfileAvatar(name: profileName),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      profileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DesktopNavItem extends StatelessWidget {
  const DesktopNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: selected
            ? AppColors.lime.withValues(alpha: .12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: selected ? AppColors.lime : AppColors.muted,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.muted,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
