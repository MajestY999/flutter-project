import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';

class PersonCard extends StatelessWidget {
  const PersonCard({super.key, 
    required this.person,
    required this.onRecordBroken,
    required this.onRecordKept,
    this.onEdit,
    this.onDelete,
  });

  final TrackedPerson person;
  final VoidCallback onRecordBroken;
  final VoidCallback onRecordKept;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: Colors.white.withValues(alpha: .055)),
      ),
      child: Row(
        children: [
          PersonAvatar(person: person, size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        person.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (person.isSelf) ...[
                      const SizedBox(width: 6),
                      const Text(
                        'ЭТО Я',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.violet,
                          letterSpacing: .6,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  person.promise,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 9,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 12,
                          color: person.broken > 0
                              ? const Color(0xFFFFA17F)
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${person.broken} срывов',
                          style: TextStyle(
                            fontSize: 10,
                            color: person.broken > 0
                                ? const Color(0xFFFFA17F)
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 12,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${person.trust}% доверия',
                          style: const TextStyle(fontSize: 10, color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          BrokenPromiseButton(name: person.name, onPressed: onRecordBroken),
          const SizedBox(width: 5),
          KeptPromiseButton(name: person.name, onPressed: onRecordKept),
          if (onEdit != null && onDelete != null)
            PopupMenuButton<String>(
              key: ValueKey('person-menu-${person.id}'),
              tooltip: 'Управление карточкой ${person.name}',
              color: AppColors.surfaceRaised,
              onSelected: (action) {
                if (action == 'edit') onEdit!();
                if (action == 'delete') onDelete!();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined, size: 18),
                    title: Text('Изменить'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, size: 18),
                    title: Text('Удалить'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.muted),
            ),
        ],
      ),
    );
  }
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, required this.size});

  final TrackedPerson person;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: person.avatarColor.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(size * .35),
        border: Border.all(
          color: person.avatarColor.withValues(alpha: .23),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          person.name.characters.first.toUpperCase(),
          style: TextStyle(
            fontSize: size * .38,
            color: person.avatarColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class BrokenPromiseButton extends StatelessWidget {
  const BrokenPromiseButton({super.key, required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('record-broken-$name'),
      label: 'Отметить срыв обещания $name',
      button: true,
      child: Material(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: const SizedBox(
            width: 43,
            height: 43,
            child: Icon(Icons.add_rounded, color: AppColors.background, size: 23),
          ),
        ),
      ),
    );
  }
}

class KeptPromiseButton extends StatelessWidget {
  const KeptPromiseButton({super.key, required this.name, required this.onPressed});

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: ValueKey('record-kept-$name'),
      label: 'Отметить сдержанное обещание $name',
      button: true,
      child: Material(
        color: const Color(0xFF83D9C4).withValues(alpha: .15),
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(13),
          child: const SizedBox(
            width: 38,
            height: 43,
            child: Icon(
              Icons.check_rounded,
              color: Color(0xFF83D9C4),
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}
