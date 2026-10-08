import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/usuario.dart';
import '../services/app_database.dart';

/// Se lanza cuando ya existe un usuario registrado con ese correo.
class EmailYaRegistradoException implements Exception {}

/// Se lanza cuando el correo o la contraseña no coinciden con ningún usuario.
class CredencialesInvalidasException implements Exception {}

/// Repositorio de usuarios, persistido en SQLite (ver [AppDatabase]).
class AuthRepository {
  AuthRepository({Future<Database> Function()? db})
    : _db = db ?? (() => AppDatabase.instancia.db);

  final Future<Database> Function() _db;

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  Future<Usuario> crearUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
  }) async {
    final db = await _db();
    final emailNormalizado = email.trim().toLowerCase();

    final existentes = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [emailNormalizado],
    );
    if (existentes.isNotEmpty) throw EmailYaRegistradoException();

    final usuario = Usuario(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nombreCompleto: nombreCompleto.trim(),
      email: emailNormalizado,
      passwordHash: _hashPassword(password),
    );
    await db.insert('usuarios', usuario.toRow());
    return usuario;
  }

  Future<Usuario> validarCredenciales({
    required String email,
    required String password,
  }) async {
    final db = await _db();
    final emailNormalizado = email.trim().toLowerCase();
    final passwordHash = _hashPassword(password);

    final filas = await db.query(
      'usuarios',
      where: 'email = ? AND passwordHash = ?',
      whereArgs: [emailNormalizado, passwordHash],
    );
    if (filas.isEmpty) throw CredencialesInvalidasException();
    return Usuario.fromRow(filas.first);
  }

  Future<Usuario?> obtenerPorId(String id) async {
    final db = await _db();
    final filas = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return Usuario.fromRow(filas.first);
  }
}
