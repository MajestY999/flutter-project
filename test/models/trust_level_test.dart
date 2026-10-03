// Проверяет расчёты процентов доверия, рангов и оставшихся обещаний.
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/models/trust_level.dart';

void main() {
  test('shows the right playful level for trust and kept promises', () {
    expect(
      levelForStats(trust: 0, kept: 0).name,
      'Призрак обещаний',
    );
    expect(
      levelForStats(trust: 46, kept: 6).name,
      'Мастер отговорок',
    );
    expect(
      levelForStats(trust: 95, kept: 40).name,
      'Легенда обещаний',
    );
    expect(levelForStats(trust: 100, kept: 1).name, 'Обещалкин');
  });

  test('calculates how many more promises must be kept', () {
    expect(
      keptPromisesNeeded(
        broken: 8,
        kept: 2,
        targetTrust: 30,
        minimumKept: 3,
      ),
      2,
    );
    expect(
      keptPromisesNeeded(
        broken: 8,
        kept: 2,
        targetTrust: 95,
        minimumKept: 40,
      ),
      150,
    );
    expect(
      keptPromisesNeeded(
        broken: 8,
        kept: 8,
        targetTrust: 50,
        minimumKept: 6,
      ),
      0,
    );
  });

  test('requires a tracked kept promise to start progress', () {
    expect(
      keptPromisesNeeded(
        broken: 0,
        kept: 0,
        targetTrust: 95,
        minimumKept: 40,
      ),
      40,
    );
  });
}
