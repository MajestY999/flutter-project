// Показывает профиль пользователя, его ранг доверия и личную карточку.
import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../models/trust_level.dart';
import '../theme/app_colors.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.name,
    required this.person,
    required this.onBack,
    required this.onEditName,
    required this.onCreateOwnCard,
    this.accountEmail,
    this.onSignOut,
  });

  final String name;
  final TrackedPerson? person;
  final VoidCallback onBack;
  final VoidCallback onEditName;
  final VoidCallback onCreateOwnCard;
  final String? accountEmail;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final broken = person?.broken ?? 0;
    final kept = person?.kept ?? 0;
    final currentTrust = person?.trust ?? 0;
    final currentLevel = levelForStats(trust: currentTrust, kept: kept);

    return CustomScrollView(
      key: const PageStorageKey('profile'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  key: const ValueKey('profile-back'),
                  onPressed: onBack,
                  tooltip: 'Вернуться',
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                if (onSignOut != null) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        if (accountEmail != null)
                          Text(
                            accountEmail!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        TextButton.icon(
                          onPressed: onSignOut,
                          icon: const Icon(Icons.logout_rounded, size: 16),
                          label: const Text('Выйти из аккаунта'),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceRaised,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.violet.withValues(alpha: .5),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            name.trim().isEmpty
                                ? '?'
                                : name.characters.first.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.violet,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onEditName,
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text('Изменить имя'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (person == null)
                  _CreateOwnCardPrompt(onCreate: onCreateOwnCard)
                else
                  _CurrentLevelCard(person: person!, level: currentLevel),
                const SizedBox(height: 24),
                const Text(
                  'УРОВНИ ДОВЕРИЯ',
                  style: TextStyle(
                    color: AppColors.lime,
                    fontSize: 10,
                    letterSpacing: 1.7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Какой следующий?',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Сдерживайте обещания — и поднимайтесь по списку.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                for (final level in trustLevels)
                  _TrustLevelCard(
                    level: level,
                    isCurrent: level == currentLevel,
                    broken: broken,
                    kept: kept,
                    currentTrust: currentTrust,
                  ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Учитываются только отмеченные обещания.',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreateOwnCardPrompt extends StatelessWidget {
  const _CreateOwnCardPrompt({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'Личной карточки пока нет',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          const Text(
            'Создайте её, чтобы отслеживать свой уровень отдельно от друзей.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 9),
          FilledButton(
            onPressed: onCreate,
            child: const Text('Создать мою карточку'),
          ),
        ],
      ),
    );
  }
}

class _CurrentLevelCard extends StatelessWidget {
  const _CurrentLevelCard({required this.person, required this.level});

  final TrackedPerson person;
  final TrustLevel level;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF28213B), Color(0xFF191823)],
        ),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: AppColors.violet.withValues(alpha: .2)),
      ),
      child: Column(
        children: [
          const Text(
            'ТВОЙ ТЕКУЩИЙ УРОВЕНЬ',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 9,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            level.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${person.trust}% доверия · ${person.kept} сдержано · ${person.broken} сорвано',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _TrustLevelCard extends StatelessWidget {
  const _TrustLevelCard({
    required this.level,
    required this.isCurrent,
    required this.broken,
    required this.kept,
    required this.currentTrust,
  });

  final TrustLevel level;
  final bool isCurrent;
  final int broken;
  final int kept;
  final int currentTrust;

  @override
  Widget build(BuildContext context) {
    final needed = keptPromisesNeeded(
      broken: broken,
      kept: kept,
      targetTrust: level.minimumTrust,
      minimumKept: level.minimumKeptPromises,
    );
    final reached =
        (level.minimumTrust == 0 && level.minimumKeptPromises == 0) ||
        (currentTrust >= level.minimumTrust &&
            kept >= level.minimumKeptPromises);

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.violet.withValues(alpha: .1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: isCurrent
              ? AppColors.violet.withValues(alpha: .45)
              : Colors.white.withValues(alpha: .05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: reached
                  ? AppColors.lime.withValues(alpha: .13)
                  : AppColors.surfaceRaised,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              reached ? Icons.check_rounded : Icons.lock_outline_rounded,
              size: 17,
              color: reached ? AppColors.lime : AppColors.muted,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        level.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isCurrent)
                      const Text(
                        'ТЕКУЩИЙ',
                        style: TextStyle(
                          color: AppColors.lime,
                          fontSize: 8,
                          letterSpacing: .7,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  level.description,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
                const SizedBox(height: 7),
                Text(
                  reached
                      ? 'Уровень получен · ${level.minimumTrust}% доверия'
                      : 'Ещё $needed ${_promiseWord(needed)} сдержать · всего минимум ${level.minimumKeptPromises} · ${level.minimumTrust}% доверия',
                  style: TextStyle(
                    color: reached ? AppColors.lime : const Color(0xFFC9B9FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _promiseWord(int count) {
  final lastTwo = count % 100;
  final last = count % 10;
  if (lastTwo >= 11 && lastTwo <= 14) return 'обещаний';
  if (last == 1) return 'обещание';
  if (last >= 2 && last <= 4) return 'обещания';
  return 'обещаний';
}
