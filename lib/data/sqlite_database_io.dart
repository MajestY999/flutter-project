// Открывает SQLite-файл на мобильных устройствах и настольных системах.
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as mobile;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as desktop;

import 'sqlite_schema.dart';

Future<Database> openGhostingDatabase() async {
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    final directory = await mobile.getDatabasesPath();
    return mobile.openDatabase(
      path.join(directory, 'ghosting_counter.db'),
      version: 2,
      onCreate: createGhostingSchema,
      onUpgrade: upgradeGhostingSchema,
    );
  }

  desktop.sqfliteFfiInit();
  final directory = await getApplicationSupportDirectory();
  final databaseDirectory = Directory(
    path.join(directory.path, 'ghosting_counter'),
  );
  await databaseDirectory.create(recursive: true);
  return desktop.databaseFactoryFfi.openDatabase(
    path.join(databaseDirectory.path, 'ghosting_counter.db'),
    options: OpenDatabaseOptions(
      version: 2,
      onCreate: createGhostingSchema,
      onUpgrade: upgradeGhostingSchema,
    ),
  );
}
