// Описывает таблицы SQLite и изменения схемы при обновлении приложения.
import 'package:sqflite_common/sqlite_api.dart';

Future<void> createGhostingSchema(Database database, int version) async {
  await database.execute('''
    CREATE TABLE people (
      id TEXT PRIMARY KEY,
      account_id TEXT NOT NULL DEFAULT '',
      name TEXT NOT NULL,
      promise TEXT NOT NULL,
      broken INTEGER NOT NULL DEFAULT 0,
      kept INTEGER NOT NULL DEFAULT 0,
      color INTEGER NOT NULL,
      is_self INTEGER NOT NULL DEFAULT 0,
      history TEXT NOT NULL
    )
  ''');
  await database.execute('''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
}

Future<void> upgradeGhostingSchema(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  if (oldVersion < 2) {
    await database.execute(
      "ALTER TABLE people ADD COLUMN account_id TEXT NOT NULL DEFAULT ''",
    );
  }
}
