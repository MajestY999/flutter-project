import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';
import 'charts.dart';
import 'common_components.dart';
import 'person_components.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key, 
    required this.people,
    required this.trust,
    required this.totalBroken,
    required this.totalKept,
  });

  final List<TrackedPerson> people;
  final int trust;
  final int totalBroken;
  final int totalKept;

  @override
  Widget build(BuildContext context) {
    final totals = List<int>.generate(7, (day) {
      return people.fold(0, (sum, person) => sum + person.history[day]);
    });
    final maxValue = totals.fold<int>(0, (a, b) => a > b ? a : b);
    const labels = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return CustomScrollView(
      key: const PageStorageKey('analytics'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const PageHeader(
                eyebrow: 'ЦИФРЫ НЕ ВРУТ',
                title: 'Аналитика',
                subtitle: 'История обещаний и уровень доверия',
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Индекс доверия',
                      value: '$trust%',
                      icon: Icons.favorite_rounded,
                      color: AppColors.lime,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Сорвано',
                      value: '$totalBroken',
                      icon: Icons.broken_image_outlined,
                      color: const Color(0xFFFF9B85),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Сдержано',
                      value: '$totalKept',
                      icon: Icons.verified_rounded,
                      color: AppColors.violet,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Под наблюдением',
                      value: '${people.length}',
                      icon: Icons.people_alt_rounded,
                      color: const Color(0xFF83D9C4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .055),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Инфляция обещаний',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Сколько обещаний не пережили эту неделю',
                      style: TextStyle(fontSize: 11, color: AppColors.muted),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 205,
                      child: PromiseTrendChart(
                        values: totals
                            .map((value) => value.toDouble())
                            .toList(),
                        labels: labels,
                        color: AppColors.violet,
                        large: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: .09),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: AppColors.violet,
                            size: 18,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              maxValue == 0
                                  ? 'Тихая неделя — ни одного нового срыва.'
                                  : 'Пик недели — $maxValue срыв(а). У кого-то опять «с понедельника».',
                              style: const TextStyle(
                                fontSize: 11,
                                height: 1.4,
                                color: Color(0xFFC7BEDD),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Рейтинг доверия',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (people.isEmpty)
                const AnalyticsEmptyCard()
              else
                ...people.map(
                  (person) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: TrustRankingCard(person: person),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({super.key, 
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 103,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: .055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -.8,
            ),
          ),
        ],
      ),
    );
  }
}

class TrustRankingCard extends StatelessWidget {
  const TrustRankingCard({super.key, required this.person});

  final TrackedPerson person;

  @override
  Widget build(BuildContext context) {
    final trustColor = person.trust >= 70
        ? AppColors.lime
        : person.trust >= 40
        ? AppColors.violet
        : const Color(0xFFFF9B85);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          PersonAvatar(person: person, size: 40),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  person.status,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 70,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: person.trust / 100,
                minHeight: 5,
                backgroundColor: Colors.white.withValues(alpha: .08),
                valueColor: AlwaysStoppedAnimation(trustColor),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 34,
            child: Text(
              '${person.trust}%',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                color: trustColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
