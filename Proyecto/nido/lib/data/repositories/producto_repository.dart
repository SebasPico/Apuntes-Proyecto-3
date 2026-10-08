import 'package:sqflite/sqflite.dart';

import '../../models/producto.dart';
import '../services/app_database.dart';

class ProductoRepository {
  ProductoRepository({Future<Database> Function()? db})
      : _db = db ?? (() => AppDatabase.instancia.db);

  final Future<Database> Function() _db;

  Future<void> crear(Producto producto) async {
    final db = await _db();
    await db.insert('productos', producto.toRow());
  }

  Future<List<Producto>> listarPorGrupo(String grupoId) async {
    final db = await _db();
    final filas = await db.query(
      'productos',
      where: 'grupoId = ?',
      whereArgs: [grupoId],
      orderBy: 'nombre ASC',
    );
    return filas.map(Producto.fromRow).toList();
  }

  Future<void> actualizar(Producto producto) async {
    final db = await _db();
    await db.update(
      'productos',
      producto.toRow(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  Future<void> eliminar(String productoId) async {
    final db = await _db();
    await db.delete(
      'productos',
      where: 'id = ?',
      whereArgs: [productoId],
    );
  }
}
