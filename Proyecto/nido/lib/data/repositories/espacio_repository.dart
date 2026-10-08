import 'package:sqflite/sqflite.dart';

import '../../models/espacio.dart';
import '../services/app_database.dart';

class EspacioRepository {
  EspacioRepository({Future<Database> Function()? db})
    : _db = db ?? (() => AppDatabase.instancia.db);

  final Future<Database> Function() _db;

  Future<void> crear(Espacio espacio) async {
    final database = await _db();
    await database.insert('espacios', espacio.toRow());
  }

  Future<List<Espacio>> listarPorGrupo(String grupoId) async {
    final database = await _db();
    final rows = await database.query(
      'espacios',
      where: 'grupoId = ?',
      whereArgs: [grupoId],
      orderBy: 'nombre ASC',
    );
    return rows.map(Espacio.fromRow).toList();
  }
}
