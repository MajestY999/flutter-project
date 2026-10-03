// Показывает подробную статистику выбранной карточки в адаптивном диалоге.
import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';
import 'person_components.dart';

class PersonDetailsDialog extends StatelessWidget {
  const PersonDetailsDialog({super.key, required this.person});

  final TrackedPerson person;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: screenSize.height - 40,
        ),
        child: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    PersonAvatar(person: person, size: 54),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (person.isSelf)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'ВАША КАРТОЧКА',
                                style: TextStyle(
                                  color: AppColors.violet,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .8,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Закрыть',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const Text(
                  'ГЛАВНОЕ ОБЕЩАНИЕ',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  person.promise,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _PersonStat(
                        label: 'Сдержано',
                        value: '${person.kept}',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF83D9C4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PersonStat(
                        label: 'Не сдержано',
                        value: '${person.broken}',
                        icon: Icons.heart_broken_outlined,
                        color: const Color(0xFFFFA17F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _PersonStat(
                  label: 'Всего отмечено',
                  value: '${person.total}',
                  icon: Icons.history_rounded,
                  color: AppColors.violet,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Уровень доверия',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${person.trust}%',
                            style: const TextStyle(
                              color: AppColors.lime,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: person.trust / 100,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: .08),
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.lime,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        person.status,
                        style: const TextStyle(
                          color: Color(0xFFC9B9FF),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Готово'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonStat extends StatelessWidget {
  const _PersonStat({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
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
