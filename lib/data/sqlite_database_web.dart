// Открывает SQLite-базу данных в браузере через веб-совместимый адаптер.
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'sqlite_schema.dart';

Future<Database> openGhostingDatabase() async {
  return databaseFactoryFfiWeb.openDatabase(
    'ghosting_counter.db',
    options: OpenDatabaseOptions(
      version: 2,
      onCreate: createGhostingSchema,
      onUpgrade: upgradeGhostingSchema,
    ),
  );
}
