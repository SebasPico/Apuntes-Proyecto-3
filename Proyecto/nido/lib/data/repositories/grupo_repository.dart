import 'dart:math';

import 'package:sqflite/sqflite.dart';

import '../../models/grupo_familiar.dart';
import '../services/app_database.dart';

/// Se lanza cuando el código de acceso ingresado no existe.
class CodigoGrupoInvalidoException implements Exception {}

/// Repositorio de grupos familiares, persistido en SQLite (ver [AppDatabase]).
class GrupoRepository {
  GrupoRepository({Future<Database> Function()? db})
    : _db = db ?? (() => AppDatabase.instancia.db);

  final Future<Database> Function() _db;

  String _generarCodigo(List<String> codigosExistentes) {
    final random = Random();
    String codigo;
    do {
      codigo = 'NIDO-${1000 + random.nextInt(9000)}';
    } while (codigosExistentes.contains(codigo));
    return codigo;
  }

  Future<GrupoFamiliar> crear({
    required String nombre,
    required String creadorId,
  }) async {
    final db = await _db();
    final filas = await db.query(
      'grupos_familiares',
      columns: ['codigoAcceso'],
    );

    final grupo = GrupoFamiliar(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombre: nombre.trim(),
      codigoAcceso: _generarCodigo(
        filas.map((f) => f['codigoAcceso'] as String).toList(),
      ),
      integrantesIds: [creadorId],
    );
    await db.insert('grupos_familiares', grupo.toRow());
    return grupo;
  }

  Future<GrupoFamiliar> unirse({
    required String codigo,
    required String usuarioId,
  }) async {
    final db = await _db();
    final codigoNormalizado = codigo.trim().toUpperCase();

    final filas = await db.query(
      'grupos_familiares',
      where: 'codigoAcceso = ?',
      whereArgs: [codigoNormalizado],
    );
    if (filas.isEmpty) throw CodigoGrupoInvalidoException();

    var grupo = GrupoFamiliar.fromRow(filas.first);
    if (!grupo.integrantesIds.contains(usuarioId)) {
      grupo = grupo.copyWith(
        integrantesIds: [...grupo.integrantesIds, usuarioId],
      );
      await db.update(
        'grupos_familiares',
        grupo.toRow(),
        where: 'id = ?',
        whereArgs: [grupo.id],
      );
    }
    return grupo;
  }

  Future<GrupoFamiliar?> obtenerGrupoDeUsuario(String usuarioId) async {
    final db = await _db();
    final filas = await db.query('grupos_familiares');
    for (final fila in filas) {
      final grupo = GrupoFamiliar.fromRow(fila);
      if (grupo.integrantesIds.contains(usuarioId)) return grupo;
    }
    return null;
  }

  Future<void> salir({
    required String grupoId,
    required String usuarioId,
  }) async {
    final db = await _db();
    final filas = await db.query(
      'grupos_familiares',
      where: 'id = ?',
      whereArgs: [grupoId],
    );
    if (filas.isEmpty) return;

    final grupoActual = GrupoFamiliar.fromRow(filas.first);
    final grupo = grupoActual.copyWith(
      integrantesIds: grupoActual.integrantesIds
          .where((id) => id != usuarioId)
          .toList(),
    );
    await db.update(
      'grupos_familiares',
      grupo.toRow(),
      where: 'id = ?',
      whereArgs: [grupoId],
    );
  }
}
