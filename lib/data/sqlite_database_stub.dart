// Сообщает об отсутствии SQLite на платформах без поддерживаемой реализации.
import 'package:sqflite_common/sqlite_api.dart';

Future<Database> openGhostingDatabase() {
  throw UnsupportedError('SQLite не поддерживается на этой платформе.');
}
