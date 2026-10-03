// Хранит ранги доверия и вычисляет требуемый прогресс до следующего уровня.
import 'dart:math' as math;

class TrustLevel {
  const TrustLevel({
    required this.name,
    required this.minimumTrust,
    required this.minimumKeptPromises,
    required this.description,
  });

  final String name;
  final int minimumTrust;
  final int minimumKeptPromises;
  final String description;
}

const trustLevels = <TrustLevel>[
  TrustLevel(
    name: 'Призрак обещаний',
    minimumTrust: 0,
    minimumKeptPromises: 0,
    description: 'Пока обещания растворяются без следа.',
  ),
  TrustLevel(
    name: 'Обещалкин',
    minimumTrust: 15,
    minimumKeptPromises: 1,
    description: 'Первый шаг от слов к делу.',
  ),
  TrustLevel(
    name: 'Пустослов',
    minimumTrust: 30,
    minimumKeptPromises: 3,
    description: 'Слова уже начинают что-то значить.',
  ),
  TrustLevel(
    name: 'Мастер отговорок',
    minimumTrust: 45,
    minimumKeptPromises: 6,
    description: 'Отговорки всё ещё летят во все стороны.',
  ),
  TrustLevel(
    name: 'Почти надёжный',
    minimumTrust: 60,
    minimumKeptPromises: 10,
    description: 'Большинство обещаний уже держится.',
  ),
  TrustLevel(
    name: 'Человек слова',
    minimumTrust: 70,
    minimumKeptPromises: 15,
    description: 'На ваше слово уже можно рассчитывать.',
  ),
  TrustLevel(
    name: 'Стальное слово',
    minimumTrust: 85,
    minimumKeptPromises: 25,
    description: 'Сорвать обещание почти невозможно.',
  ),
  TrustLevel(
    name: 'Легенда обещаний',
    minimumTrust: 95,
    minimumKeptPromises: 40,
    description: 'Ваши обещания переживут даже понедельник.',
  ),
];

TrustLevel levelForStats({required int trust, required int kept}) =>
    trustLevels.lastWhere(
  (level) =>
      trust >= level.minimumTrust && kept >= level.minimumKeptPromises,
  orElse: () => trustLevels.first,
);

int keptPromisesNeeded({
  required int broken,
  required int kept,
  required int targetTrust,
  required int minimumKept,
}) {
  if (targetTrust <= 0) return 0;
  final total = broken + kept;
  final trust = total == 0 ? 0 : (kept * 100 / total).round();
  if (trust >= targetTrust && kept >= minimumKept) return 0;

  final successesNeeded =
      ((targetTrust * broken - (100 - targetTrust) * kept) /
              (100 - targetTrust))
          .ceil()
      .clamp(0, 1 << 31);

  final countNeeded = math.max(minimumKept - kept, 0);
  return math.max(
    countNeeded,
    total == 0 ? math.max(successesNeeded, 1) : successesNeeded,
  );
}
