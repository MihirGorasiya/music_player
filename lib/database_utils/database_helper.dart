import 'dart:io';

import 'package:music_player/database_utils/SongInfo.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const int version = 1;
  static const String dbName = "songInfo.db";

  static Future<Database> _getDB() async {
    Directory? dir = await getExternalStorageDirectory();
    String path = '${dir!.path}/songInfos';

    return openDatabase(
      join(path, dbName),
      onCreate: (db, version) async => await db.execute(
        'CREATE TABLE songInfo(id INTEGER PRIMARY KEY, songName TEXT, imagePath TEXT, songPath Text)',
      ),
      version: version,
    );
  }

  static Future<int> addData(SongInfo info) async {
    final db = await _getDB();
    return await db.insert(
      "songInfo",
      info.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int> updateData(SongInfo info) async {
    final db = await _getDB();
    return await db.update(
      "songInfo",
      info.toJson(),
      where: 'id = ?',
      whereArgs: [info.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteData() async {
    try {
      final db = await _getDB();
      await db.transaction((txn) async {
        var batch = txn.batch();
        batch.delete('songInfo');
        await batch.commit();
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<List<SongInfo>?> getAllNotes() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      "songInfo",
      orderBy: "songName ASC",
    );
    if (maps.isEmpty) return null;
    return List.generate(
      maps.length,
      (index) => SongInfo.fromJson(maps[index]),
    );
  }
}
