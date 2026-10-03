import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../models/tracked_person.dart';
import 'sqlite_database.dart';

abstract interface class PeopleRepository {
  Future<List<TrackedPerson>?> loadPeople();
  Future<void> savePeople(List<TrackedPerson> people);
  Future<String?> loadProfileName();
  Future<void> saveProfileName(String name);
}

class SqlitePeopleRepository implements PeopleRepository {
  SqlitePeopleRepository({
    this.accountId = 'local',
    this.showSampleDataWhenEmpty = true,
    Future<Database> Function()? openDatabase,
  })
    : _openDatabase = openDatabase ?? openGhostingDatabase;

  static const _legacyPeopleKey = 'ghosting_counter_people_v1';
  static const _legacyProfileKey = 'ghosting_counter_profile_name_v1';
  static const _legacyProfileSettingKey = 'profile_name';

  final String accountId;
  final bool showSampleDataWhenEmpty;
  final Future<Database> Function() _openDatabase;
  Future<Database>? _database;
  Future<void>? _migration;

  String get _profileKey => '$accountId:profile_name';

  Future<Database> get _db => _database ??= _openDatabase();

  Future<void> _ensureMigrated(Database database) =>
      _migration ??= _migrateLegacyPreferences(database);

  Future<void> _migrateLegacyPreferences(Database database) async {
    final preferences = await SharedPreferences.getInstance();
    final legacyPeople = preferences.getString(_legacyPeopleKey);
    final legacyProfile = preferences.getString(_legacyProfileKey);
    final existingPeople = await database.query(
      'people',
      columns: ['id'],
      where: 'account_id = ?',
      whereArgs: [accountId],
      limit: 1,
    );
    final unassignedPeople = await database.query(
      'people',
      columns: ['id'],
      where: "account_id = ''",
      limit: 1,
    );
    final existingProfile = await database.query(
      'settings',
      columns: ['key'],
      where: 'key = ?',
      whereArgs: [_profileKey],
      limit: 1,
    );
    final legacyProfileSetting = await database.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_legacyProfileSettingKey],
      limit: 1,
    );

    await database.transaction((transaction) async {
      if (existingPeople.isEmpty && unassignedPeople.isNotEmpty) {
        await transaction.update(
          'people',
          {'account_id': accountId},
          where: "account_id = ''",
        );
      } else if (existingPeople.isEmpty && legacyPeople != null) {
        final decoded = jsonDecode(legacyPeople) as List<dynamic>;
        for (final entry in decoded) {
          final person = TrackedPerson.fromJson(entry as Map<String, dynamic>);
          await transaction.insert('people', _toRow(person));
        }
      }
      if (existingProfile.isEmpty &&
          legacyProfileSetting.isNotEmpty) {
        await transaction.insert('settings', {
          'key': _profileKey,
          'value': legacyProfileSetting.first['value'],
        });
        await transaction.delete(
          'settings',
          where: 'key = ?',
          whereArgs: [_legacyProfileSettingKey],
        );
      } else if (existingProfile.isEmpty && legacyProfile != null) {
        await transaction.insert('settings', {
          'key': _profileKey,
          'value': legacyProfile,
        });
      }
    });

    if (legacyPeople != null || legacyProfile != null) {
      await preferences.remove(_legacyPeopleKey);
      await preferences.remove(_legacyProfileKey);
    }
  }

  @override
  Future<List<TrackedPerson>?> loadPeople() async {
    final database = await _db;
    await _ensureMigrated(database);
    final rows = await database.query(
      'people',
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'rowid',
    );
    if (rows.isEmpty) {
      return showSampleDataWhenEmpty ? null : <TrackedPerson>[];
    }
    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> savePeople(List<TrackedPerson> people) async {
    final database = await _db;
    await _ensureMigrated(database);
    await database.transaction((transaction) async {
      await transaction.delete(
        'people',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );
      for (final person in people) {
        await transaction.insert('people', _toRow(person));
      }
    });
  }

  @override
  Future<String?> loadProfileName() async {
    final database = await _db;
    await _ensureMigrated(database);
    final rows = await database.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_profileKey],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  @override
  Future<void> saveProfileName(String name) async {
    final database = await _db;
    await _ensureMigrated(database);
    await database.insert('settings', {
      'key': _profileKey,
      'value': name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Map<String, Object?> _toRow(TrackedPerson person) => {
    'id': person.id,
    'account_id': accountId,
    'name': person.name,
    'promise': person.promise,
    'broken': person.broken,
    'kept': person.kept,
    'color': person.color,
    'is_self': person.isSelf ? 1 : 0,
    'history': jsonEncode(person.history),
  };

  TrackedPerson _fromRow(Map<String, Object?> row) => TrackedPerson(
    id: row['id'] as String,
    name: row['name'] as String,
    promise: row['promise'] as String,
    broken: row['broken'] as int,
    kept: row['kept'] as int,
    color: row['color'] as int,
    isSelf: row['is_self'] == 1,
    history: (jsonDecode(row['history'] as String) as List<dynamic>)
        .cast<int>(),
  );
}
