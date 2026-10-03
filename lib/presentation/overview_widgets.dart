// Собирает обзорный экран: приветствие, доверие, карточки людей и мини-график.
import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';
import 'charts.dart';
import 'common_components.dart';
import 'person_components.dart';
import 'trust_components.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.people,
    required this.profileName,
    required this.trust,
    required this.totalBroken,
    required this.onAddPerson,
    required this.onEditProfile,
    required this.onRecordBroken,
    required this.onRecordKept,
    this.onOpenPerson,
    required this.onViewAnalytics,
    required this.onViewPeople,
    this.onSignOut,
  });

  final List<TrackedPerson> people;
  final String profileName;
  final int trust;
  final int totalBroken;
  final VoidCallback onAddPerson;
  final VoidCallback onEditProfile;
  final ValueChanged<String> onRecordBroken;
  final ValueChanged<String> onRecordKept;
  final ValueChanged<TrackedPerson>? onOpenPerson;
  final VoidCallback onViewAnalytics;
  final VoidCallback onViewPeople;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return CustomScrollView(
      key: const PageStorageKey('overview'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              TopBar(
                onAdd: onAddPerson,
                onProfile: onEditProfile,
                profileName: profileName,
                onSignOut: onSignOut,
              ),
              const SizedBox(height: 26),
              Text(
                '${greeting(now.hour)}, $profileName 👋',
                style: const TextStyle(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Кажется, кто-то опять что-то обещал.',
                style: TextStyle(fontSize: 14, color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              TrustCard(
                trust: trust,
                kept: people.fold(0, (sum, person) => sum + person.kept),
                broken: totalBroken,
                onAnalytics: onViewAnalytics,
              ),
              const SizedBox(height: 29),
              SectionHeading(
                title: 'Под подозрением',
                subtitle: '${people.length} в списке',
                actionLabel: 'Все',
                onAction: onViewPeople,
              ),
              const SizedBox(height: 13),
              if (people.isEmpty)
                EmptyPeopleCard(onAddPerson: onAddPerson)
              else
                ...people
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PersonCard(
                          person: entry.value,
                          onRecordBroken: () => onRecordBroken(entry.value.id),
                          onRecordKept: () => onRecordKept(entry.value.id),
                          onTap: onOpenPerson == null
                              ? null
                              : () => onOpenPerson!(entry.value),
                        ),
                      ),
                    ),
              if (people.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: SeeAllButton(onPressed: onViewPeople),
                ),
              const SizedBox(height: 20),
              SectionHeading(
                title: 'Инфляция обещаний',
                subtitle: 'за последние 7 дней',
                actionLabel: 'Подробнее',
                onAction: onViewAnalytics,
              ),
              const SizedBox(height: 13),
              MiniChartCard(people: people),
              const SizedBox(height: 24),
              const GhostingFooter(),
            ]),
          ),
        ),
      ],
    );
  }
}

String greeting(int hour) {
  if (hour < 6) return 'Доброй ночи';
  if (hour < 12) return 'Доброе утро';
  if (hour < 18) return 'Добрый день';
  return 'Добрый вечер';
}

class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.onAdd,
    required this.onProfile,
    required this.profileName,
    this.onSignOut,
  });

  final VoidCallback onAdd;
  final VoidCallback onProfile;
  final String profileName;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.background,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GHOSTING',
              style: TextStyle(
                fontSize: 13,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'PROMISE TRACKER',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.muted,
                letterSpacing: 1.25,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconActionButton(
          icon: Icons.add_rounded,
          label: 'Добавить человека',
          onPressed: onAdd,
        ),
        if (onSignOut != null) ...[
          const SizedBox(width: 8),
          IconActionButton(
            icon: Icons.logout_rounded,
            label: 'Выйти из аккаунта',
            onPressed: onSignOut!,
          ),
        ],
        const SizedBox(width: 9),
        Tooltip(
          message: 'Редактировать профиль',
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: onProfile,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ProfileAvatar(name: profileName, size: 38),
            ),
          ),
        ),
      ],
    );
  }
}

class IconActionButton extends StatelessWidget {
  const IconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
          side: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 21, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: AppColors.background,
            size: 23,
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GHOSTING',
              style: TextStyle(
                fontSize: 13,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'PROMISE TRACKER',
              style: TextStyle(
                fontSize: 8,
                color: AppColors.muted,
                letterSpacing: 1.25,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, required this.name, this.size = 38});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.characters.first;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceRaised,
        border: Border.all(color: AppColors.violet.withValues(alpha: .4)),
      ),
      child: Center(
        child: Text(
          initial.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.violet,
          ),
        ),
      ),
    );
  }
}
