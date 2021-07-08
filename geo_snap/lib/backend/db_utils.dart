import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBUtils {
  static Future<Database> init() async {
    var database = openDatabase(
      path.join(await getDatabasesPath(), 'preferences_manager.db'),
      onCreate: (db, version) {
        db.execute('CREATE TABLE preferences_items(' +
            'id INTEGER PRIMARY KEY,' +
            'language TEXT,' + // localization (ex. en, fr, jp)
            'imageSize TEXT)'); // homepage image size (small, medium, large)
        //'lastLoginDate TEXT)'); // notifications (ex. "here's what you've missed since X")
      },
      version: 1,
    );
    return database;
  }
}
