import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:my_app/data/people_repository.dart';
import 'package:my_app/data/sqlite_schema.dart';
import 'package:my_app/models/tracked_person.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('stores people and profile name in SQLite', () async {
    final repository = _newRepository();
    final person = samplePeople().first;

    await repository.savePeople([person]);
    await repository.saveProfileName('Алина');

    final restoredPeople = await repository.loadPeople();
    final restoredName = await repository.loadProfileName();

    expect(restoredPeople, hasLength(1));
    expect(restoredPeople!.single.toJson(), person.toJson());
    expect(restoredName, 'Алина');
  });

  test('migrates data saved by the previous local repository', () async {
    SharedPreferences.setMockInitialValues({
      'ghosting_counter_people_v1': '[${_legacyPersonJson()}]',
      'ghosting_counter_profile_name_v1': 'Саша',
    });
    final repository = _newRepository();

    final people = await repository.loadPeople();
    final profileName = await repository.loadProfileName();

    expect(people, hasLength(1));
    expect(people!.single.id, 'Саша');
    expect(people.single.broken, 2);
    expect(profileName, 'Саша');
  });

  test('isolates local cards and profile names by account', () async {
    final database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        singleInstance: false,
        onCreate: createGhostingSchema,
      ),
    );
    final firstAccount = SqlitePeopleRepository(
      accountId: 'account-one',
      openDatabase: () async => database,
    );
    final secondAccount = SqlitePeopleRepository(
      accountId: 'account-two',
      showSampleDataWhenEmpty: false,
      openDatabase: () async => database,
    );
    final person = samplePeople().first;

    await firstAccount.savePeople([person]);
    await firstAccount.saveProfileName('Алина');

    expect(await secondAccount.loadPeople(), isEmpty);
    expect(await secondAccount.loadProfileName(), isNull);

    await secondAccount.saveProfileName('Борис');
    expect(await firstAccount.loadPeople(), hasLength(1));
    expect(await firstAccount.loadProfileName(), 'Алина');
    expect(await secondAccount.loadProfileName(), 'Борис');
  });

  test('upgrades existing local SQLite data to the first account', () async {
    final directory = await Directory.systemTemp.createTemp(
      'ghosting-counter-migration-',
    );
    final databasePath = path.join(directory.path, 'previous.db');
    Database? upgradedDatabase;
    try {
      final oldDatabase = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, version) async {
            await database.execute('''
              CREATE TABLE people (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                promise TEXT NOT NULL,
                broken INTEGER NOT NULL,
                kept INTEGER NOT NULL,
                color INTEGER NOT NULL,
                is_self INTEGER NOT NULL,
                history TEXT NOT NULL
              )
            ''');
            await database.execute('''
              CREATE TABLE settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
              )
            ''');
          },
        ),
      );
      await oldDatabase.insert('people', {
        'id': 'legacy-person',
        'name': 'Саша',
        'promise': 'Позвоню',
        'broken': 2,
        'kept': 1,
        'color': 0xFFFFFFFF,
        'is_self': 0,
        'history': '[0,0,0,0,0,0,0]',
      });
      await oldDatabase.insert('settings', {
        'key': 'profile_name',
        'value': 'Саша',
      });
      await oldDatabase.close();

      final repository = SqlitePeopleRepository(
        accountId: 'first-account',
        showSampleDataWhenEmpty: false,
        openDatabase: () async {
          upgradedDatabase = await databaseFactoryFfi.openDatabase(
            databasePath,
            options: OpenDatabaseOptions(
              version: 2,
              onCreate: createGhostingSchema,
              onUpgrade: upgradeGhostingSchema,
            ),
          );
          return upgradedDatabase!;
        },
      );

      final people = await repository.loadPeople();
      final profileName = await repository.loadProfileName();

      expect(people, hasLength(1));
      expect(people!.single.id, 'legacy-person');
      expect(profileName, 'Саша');
    } finally {
      await upgradedDatabase?.close();
      await directory.delete(recursive: true);
    }
  });
}

SqlitePeopleRepository _newRepository() {
  return SqlitePeopleRepository(
    openDatabase: () => databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 2,
        singleInstance: false,
        onCreate: createGhostingSchema,
      ),
    ),
  );
}

String _legacyPersonJson() =>
    '{"name":"Саша","promise":"«Позвоню»","broken":2,"kept":1,'
    '"color":4294967295,"isSelf":true,"history":[1,0,0,0,0,0,0]}';
