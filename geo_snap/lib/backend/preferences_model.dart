import 'package:sqflite/sqflite.dart';
import 'package:geo_snap/backend/db_utils.dart';
import 'package:geo_snap/backend/preferences.dart';

class PreferencesModel {
  Future<int> insertPreferences(Preferences preferences) async {
    final db = await DBUtils.init();
    return db.insert(
      'preferences_items',
      preferences.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Preferences>> getAllPreferences() async {
    final db = await DBUtils.init();
    final List<Map<String, dynamic>> maps = await db.query('preferences_items');
    List<Preferences> result = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        result.add(Preferences.fromMap(maps[i]));
      }
    }
    return result;
  }

  Future<void> updatePreferences(Preferences preferences) async {
    final db = await DBUtils.init();
    await db.update(
      'preferences_items',
      preferences.toMap(),
      where: 'id = ?',
      whereArgs: [preferences.id],
    );
  }
}
