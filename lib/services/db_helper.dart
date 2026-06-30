import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<sql.Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'myshop.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE cart_items(productId TEXT, id TEXT, userId TEXT, title TEXT, imageUrl TEXT, price REAL, quantity INTEGER, color TEXT, size TEXT, PRIMARY KEY(productId, userId))',
        );
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object?> data) async {
    final db = await DBHelper.database();
    await db.insert(table, data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getData(String table, String userId) async {
    final db = await DBHelper.database();
    return db.query(table, where: 'userId = ?', whereArgs: [userId]);
  }

  static Future<void> updateQuantity(String table, String productId, String userId, int quantity) async {
    final db = await DBHelper.database();
    await db.update(table, {'quantity': quantity}, where: 'productId = ? AND userId = ?', whereArgs: [productId, userId]);
  }

  static Future<void> delete(String table, String productId, String userId) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'productId = ? AND userId = ?', whereArgs: [productId, userId]);
  }

  static Future<void> clear(String table, String userId) async {
    final db = await DBHelper.database();
    await db.delete(table, where: 'userId = ?', whereArgs: [userId]);
  }
}