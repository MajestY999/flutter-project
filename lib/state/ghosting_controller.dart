// Управляет списком людей, статистикой, профилем и сохранением изменений.
import 'package:flutter/foundation.dart';

import '../data/people_repository.dart';
import '../models/tracked_person.dart';

class GhostingController extends ChangeNotifier {
  GhostingController(
    this._repository, {
    String initialProfileName = 'Алексей',
  }) : _profileName = initialProfileName;

  final PeopleRepository _repository;
  List<TrackedPerson> _people = samplePeople();
  String _profileName;
  bool _isLoading = true;

  List<TrackedPerson> get people => List.unmodifiable(_people);
  String get profileName => _profileName;
  bool get isLoading => _isLoading;
  int get totalBroken => _people.fold(0, (sum, person) => sum + person.broken);
  int get totalKept => _people.fold(0, (sum, person) => sum + person.kept);
  int get trust {
    final total = totalBroken + totalKept;
    return total == 0 ? 0 : (totalKept * 100 / total).round();
  }

  Future<void> load() async {
    final results = await Future.wait<Object?>([
      _repository.loadPeople(),
      _repository.loadProfileName(),
    ]);
    final storedPeople = results[0] as List<TrackedPerson>?;
    final storedName = results[1] as String?;
    if (storedPeople != null) _people = storedPeople;
    if (storedName != null && storedName.isNotEmpty) {
      _profileName = storedName;
    } else {
      await _repository.saveProfileName(_profileName);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPerson({
    required String name,
    required String promise,
    required bool isSelf,
    required int broken,
    required int kept,
  }) async {
    final person = TrackedPerson(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      promise: promise,
      broken: broken,
      kept: kept,
      color: avatarColorFor(_people.length).toARGB32(),
      isSelf: isSelf,
      history: List.filled(7, 0),
    );
    _people = [..._people, person];
    notifyListeners();
    await _persistPeople();
  }

  Future<void> updatePerson({
    required String id,
    required String name,
    required String promise,
    required bool isSelf,
    required int broken,
    required int kept,
  }) async {
    _people = [
      for (final person in _people)
        if (person.id == id)
          person.copyWith(
            name: name,
            promise: promise,
            isSelf: isSelf,
            broken: broken,
            kept: kept,
          )
        else
          person,
    ];
    notifyListeners();
    await _persistPeople();
  }

  Future<void> deletePerson(String id) async {
    _people = _people.where((person) => person.id != id).toList();
    notifyListeners();
    await _persistPeople();
  }

  Future<void> recordBroken(String id) async {
    _changeCounts(id, brokenDelta: 1);
    await _persistPeople();
  }

  Future<void> recordKept(String id) async {
    _changeCounts(id, keptDelta: 1);
    await _persistPeople();
  }

  Future<void> updateProfileName(String name) async {
    _profileName = name;
    notifyListeners();
    await _repository.saveProfileName(name);
  }

  void _changeCounts(String id, {int brokenDelta = 0, int keptDelta = 0}) {
    final index = _people.indexWhere((person) => person.id == id);
    if (index == -1) throw StateError('Карточка человека не найдена.');
    final person = _people[index];
    final history = [...person.history];
    if (brokenDelta > 0) history[DateTime.now().weekday - 1] += brokenDelta;
    _people = [
      for (var i = 0; i < _people.length; i++)
        if (i == index)
          person.copyWith(
            broken: person.broken + brokenDelta,
            kept: person.kept + keptDelta,
            history: history,
          )
        else
          _people[i],
    ];
    notifyListeners();
  }

  Future<void> _persistPeople() => _repository.savePeople(_people);
}
