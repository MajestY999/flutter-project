import 'package:sqflite_common/sqlite_api.dart';

import 'sqlite_database_stub.dart'
    if (dart.library.io) 'sqlite_database_io.dart'
    if (dart.library.js_interop) 'sqlite_database_web.dart' as implementation;

Future<Database> openGhostingDatabase() =>
    implementation.openGhostingDatabase();
