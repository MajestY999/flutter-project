import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tracked_person.dart';

abstract interface class PeopleRepository {
  Future<List<TrackedPerson>?> loadPeople();
  Future<void> savePeople(List<TrackedPerson> people);
  Future<String?> loadProfileName();
  Future<void> saveProfileName(String name);
}

class SharedPreferencesPeopleRepository implements PeopleRepository {
  static const _peopleKey = 'ghosting_counter_people_v1';
  static const _profileKey = 'ghosting_counter_profile_name_v1';

  @override
  Future<List<TrackedPerson>?> loadPeople() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_peopleKey);
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => TrackedPerson.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> savePeople(List<TrackedPerson> people) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _peopleKey,
      jsonEncode(people.map((person) => person.toJson()).toList()),
    );
    if (!saved) throw StateError('Не удалось сохранить список обещаний.');
  }

  @override
  Future<String?> loadProfileName() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_profileKey);
  }

  @override
  Future<void> saveProfileName(String name) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(_profileKey, name);
    if (!saved) throw StateError('Не удалось сохранить имя профиля.');
  }
}
