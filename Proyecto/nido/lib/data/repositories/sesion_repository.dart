import 'package:sqflite/sqflite.dart';

import '../services/app_database.dart';

/// Guarda qué usuario tiene la sesión activa, para no pedir login otra vez.
class SesionRepository {
  SesionRepository({Future<Database> Function()? db})
    : _db = db ?? (() => AppDatabase.instancia.db);

  final Future<Database> Function() _db;

  Future<void> guardar(String usuarioId) async {
    final db = await _db();
    await db.insert('sesion', {
      'id': 0,
      'usuarioId': usuarioId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> obtener() async {
    final db = await _db();
    final filas = await db.query('sesion', where: 'id = 0');
    if (filas.isEmpty) return null;
    return filas.first['usuarioId'] as String?;
  }

  Future<void> limpiar() async {
    final db = await _db();
    await db.delete('sesion', where: 'id = 0');
  }
}
