// Показывает список карточек и кнопку добавления нового человека.
import 'package:flutter/material.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';
import 'common_components.dart';
import 'person_components.dart';

class PeopleTab extends StatelessWidget {
  const PeopleTab({super.key, 
    required this.people,
    required this.onAddPerson,
    required this.onEditPerson,
    this.onOpenPerson,
    required this.onRecordBroken,
    required this.onRecordKept,
    required this.onDeletePerson,
  });

  final List<TrackedPerson> people;
  final VoidCallback onAddPerson;
  final ValueChanged<TrackedPerson> onEditPerson;
  final ValueChanged<TrackedPerson>? onOpenPerson;
  final ValueChanged<String> onRecordBroken;
  final ValueChanged<String> onRecordKept;
  final ValueChanged<String> onDeletePerson;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('people'),
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              PageHeader(
                eyebrow: 'ЛИЧНОЕ ДЕЛО',
                title: 'Мои люди',
                subtitle:
                    '${people.length} ${peopleLabel(people.length)} на карандаше',
              ),
              const SizedBox(height: 20),
              AddPersonButton(onPressed: onAddPerson),
              const SizedBox(height: 17),
              if (people.isEmpty)
                EmptyPeopleCard(onAddPerson: onAddPerson),
            ]),
          ),
        ),
        if (people.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            sliver: SliverList.builder(
              itemCount: people.length,
              itemBuilder: (context, index) {
                final person = people[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PersonCard(
                    person: person,
                    onRecordBroken: () => onRecordBroken(person.id),
                    onRecordKept: () => onRecordKept(person.id),
                    onTap: onOpenPerson == null
                        ? null
                        : () => onOpenPerson!(person),
                    onEdit: () => onEditPerson(person),
                    onDelete: () => onDeletePerson(person.id),
                  ),
                );
              },
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(22, 12, 22, 28),
          sliver: SliverToBoxAdapter(child: GhostingFooter()),
        ),
      ],
    );
  }
}

String peopleLabel(int count) {
  if (count % 10 == 1 && count % 100 != 11) return 'человек';
  if (count % 10 >= 2 &&
      count % 10 <= 4 &&
      (count % 100 < 12 || count % 100 > 14)) {
    return 'человека';
  }
  return 'человек';
}

class AddPersonButton extends StatelessWidget {
  const AddPersonButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lime,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.background,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Добавить обещателя',
                style: TextStyle(
                  color: AppColors.background,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
