import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, 
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.lime,
            letterSpacing: 1.7,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
      ],
    );
  }
}

class EmptyPeopleCard extends StatelessWidget {
  const EmptyPeopleCard({super.key, required this.onAddPerson});

  final VoidCallback onAddPerson;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_search_rounded, color: AppColors.violet, size: 30),
          const SizedBox(height: 9),
          const Text(
            'Пока всё тихо',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          const Text(
            'Добавьте человека и начните вести счёт обещаниям.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
          const SizedBox(height: 13),
          TextButton(
            onPressed: onAddPerson,
            child: const Text(
              'Добавить первого',
              style: TextStyle(color: AppColors.lime),
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsEmptyCard extends StatelessWidget {
  const AnalyticsEmptyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'Рейтинг появится, когда вы добавите людей.',
        style: TextStyle(fontSize: 12, color: AppColors.muted),
      ),
    );
  }
}

class SeeAllButton extends StatelessWidget {
  const SeeAllButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: const Text(
        'Показать всех',
        style: TextStyle(color: AppColors.lime, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class GhostingFooter extends StatelessWidget {
  const GhostingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: AppColors.lime, size: 14),
          SizedBox(width: 5),
          Text(
            'GHOSTING · данные только на этом устройстве',
            style: TextStyle(fontSize: 10, color: Color(0xFF77737F)),
          ),
        ],
      ),
    );
  }
}
